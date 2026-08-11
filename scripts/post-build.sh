#!/bin/bash

# Generate bzImage and Kernel Modules VHDX after build

set -euo pipefail

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h|--help                   - Show this help message."
    echo "  -n|--name <image name>          - Specify the name of the output image. (Default: bzImage-x64v3)"
}

# Parse options with getopt
temp=$(getopt -o 'hn:' --long 'help,name:' -n 'post-build.sh' -- "$@")
if [ $? -ne 0 ]; then
    # unsupported options provided
    usage
    exit 1
fi
eval set -- "$temp"
unset temp
while true; do
    case "$1" in
        '-h'|'--help')
            usage
            exit 0
            ;;
        '-n'|'--name')
            IMAGE_NAME="$2"
            shift 2
            continue
            ;;
        '--')
            shift
            break
            ;;
        *)
            # should not happen
            echo "Unhandled option: $1"
            usage
            exit 1
            ;;
    esac
done
# Default values
IMAGE_NAME=${IMAGE_NAME:-bzImage-x64v3}

# Get Kernel Version
KERNEL_VERSION=$(make -s LLVM=1 LLVM_IAS=1 kernelrelease)

# Use isolated staging so repeated builds cannot mix artifacts from different
# kernel versions.
ADDONS_BUILD_DIR=$(mktemp -d -p "$PWD" ".${IMAGE_NAME}-addons.XXXXXX")
trap 'rm -rf "$ADDONS_BUILD_DIR"' EXIT
MODULES_INSTALL_DIR="$ADDONS_BUILD_DIR/modules"
MODULES_DIR="$MODULES_INSTALL_DIR/lib/modules/$KERNEL_VERSION"
HEADERS_DIR="$MODULES_DIR/build"

# Generate kernel modules and replace build-time links with a self-contained
# external-module build tree. This helper is shared by the kernel's native
# package targets and tracks kbuild's required files as they evolve.
make LLVM=1 LLVM_IAS=1 \
    INSTALL_MOD_PATH="$MODULES_INSTALL_DIR" \
    INSTALL_MOD_STRIP=1 \
    modules_install
rm -f "$MODULES_DIR/build" "$MODULES_DIR/source"
make LLVM=1 LLVM_IAS=1 run-command \
    KBUILD_RUN_COMMAND='${srctree}/scripts/package/install-extmod-build "'"$HEADERS_DIR"'"'

# Keep the exported userspace API separate from kbuild's internal headers.
# Consumers can opt in to this kernel-specific UAPI without replacing their
# distribution's libc headers.
make LLVM=1 LLVM_IAS=1 INSTALL_HDR_PATH="$HEADERS_DIR/usr" headers_install

# Ship the documentation for the exact kernel sources used by this build.
cp -a Documentation "$HEADERS_DIR/"
install -m 644 README COPYING System.map "$HEADERS_DIR/"
cp .config "$HEADERS_DIR/Documentation/config-$KERNEL_VERSION"

# Validate all three advertised addon interfaces before creating the VHDX.
test -f "$HEADERS_DIR/Module.symvers"
test -f "$HEADERS_DIR/usr/include/linux/version.h"
test -f "$HEADERS_DIR/Documentation/index.rst"

SMOKE_TEST_DIR="$ADDONS_BUILD_DIR/external-module-smoke-test"
mkdir -p "$SMOKE_TEST_DIR"
cat >"$SMOKE_TEST_DIR/Makefile" <<'EOF'
obj-m := wsl_addon_smoke.o
EOF
cat >"$SMOKE_TEST_DIR/wsl_addon_smoke.c" <<'EOF'
#include <linux/init.h>
#include <linux/module.h>

static int __init wsl_addon_smoke_init(void)
{
    return 0;
}

static void __exit wsl_addon_smoke_exit(void)
{
}

module_init(wsl_addon_smoke_init);
module_exit(wsl_addon_smoke_exit);
MODULE_DESCRIPTION("WSL addon header smoke test");
MODULE_LICENSE("GPL");
EOF
make -s -C "$HEADERS_DIR" LLVM=1 LLVM_IAS=1 M="$SMOKE_TEST_DIR" modules
test -f "$SMOKE_TEST_DIR/wsl_addon_smoke.ko"

cat >"$SMOKE_TEST_DIR/uapi-smoke.c" <<'EOF'
#include <linux/version.h>

int uapi_version = LINUX_VERSION_CODE;
EOF
clang -nostdinc -I"$HEADERS_DIR/usr/include" \
    -c "$SMOKE_TEST_DIR/uapi-smoke.c" \
    -o "$SMOKE_TEST_DIR/uapi-smoke.o"

# Create VHDX for Kernel Modules
../scripts/gen_modules_vhdx.sh "$MODULES_INSTALL_DIR" "$KERNEL_VERSION" "${IMAGE_NAME}-addons.vhdx"

# Compress the addon VHDX to reduce release and install size.
7z a -mx=9 "${IMAGE_NAME}-addons.vhdx.7z" "${IMAGE_NAME}-addons.vhdx" >/dev/null
rm -f "${IMAGE_NAME}-addons.vhdx"

# move generated files to upper directory
mv arch/x86/boot/bzImage ../$IMAGE_NAME
mv ./$IMAGE_NAME-addons.vhdx.7z ../

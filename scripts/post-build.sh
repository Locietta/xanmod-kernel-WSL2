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
KERNEL_VERSION=$(make -s kernelrelease)

# Use isolated staging directories so a failed or repeated build cannot mix
# artifacts from different kernel versions.
ARTIFACTS_BUILD_DIR=$(mktemp -d -p "$PWD" ".${IMAGE_NAME}-artifacts.XXXXXX")
trap 'rm -rf "$ARTIFACTS_BUILD_DIR"' EXIT
MODULES_DIR="$ARTIFACTS_BUILD_DIR/modules"
HEADERS_DIR="$ARTIFACTS_BUILD_DIR/headers"
PERF_DIR="$ARTIFACTS_BUILD_DIR/perf"

# Generate kernel modules and install the exported userspace API headers.
make INSTALL_MOD_PATH="$MODULES_DIR" INSTALL_MOD_STRIP=1 modules_install
make INSTALL_HDR_PATH="$HEADERS_DIR" headers_install

# Build perf with the same reduced dependency set used by the official WSL
# custom-kernel instructions. DESTDIR receives bin/perf beneath PERF_DIR.
make -C tools/perf \
    NO_JEVENTS=1 \
    NO_JVMTI=1 \
    NO_LIBTRACEEVENT=1 \
    WERROR=0 \
    install \
    DESTDIR="$PERF_DIR" \
    prefix=/

# Create the artifact VHDX using WSL's kernelrelease/{modules,linux-headers,
# perf} layout.
../scripts/gen_artifacts_vhdx.sh \
    "$MODULES_DIR" \
    "$HEADERS_DIR" \
    "$PERF_DIR" \
    "$KERNEL_VERSION" \
    "${IMAGE_NAME}-addons.vhdx"

# Compress the addon VHDX to reduce release and install size.
7z a -mx=9 "${IMAGE_NAME}-addons.vhdx.7z" "${IMAGE_NAME}-addons.vhdx" >/dev/null
rm -f "${IMAGE_NAME}-addons.vhdx"

# move generated files to upper directory
mv arch/x86/boot/bzImage ../$IMAGE_NAME
mv ./$IMAGE_NAME-addons.vhdx.7z ../

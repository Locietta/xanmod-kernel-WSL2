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

# Generate Kernel Modules
mkdir -p $IMAGE_NAME-addons
make INSTALL_MOD_PATH=$IMAGE_NAME-addons INSTALL_MOD_STRIP=1 modules_install

rm -f "$IMAGE_NAME-addons/lib/modules/$KERNEL_VERSION/build"

# Create a directory for kernel headers inside the VHDX
HEADERS_DIR="$IMAGE_NAME-addons/lib/modules/$KERNEL_VERSION/build"
mkdir -p "$HEADERS_DIR"

# Install kernel headers
make INSTALL_HDR_PATH="$HEADERS_DIR/usr" headers_install

# Copy essential build files
cp .config Module.symvers System.map Makefile "$HEADERS_DIR/"

cp -r scripts "$HEADERS_DIR/"
cp -r include "$HEADERS_DIR/"

mkdir -p "$HEADERS_DIR/arch/x86"
cp -r arch/x86/include "$HEADERS_DIR/arch/x86/"
cp arch/x86/Makefile* "$HEADERS_DIR/arch/x86/" 2>/dev/null || true

# Copy module.lds if it exists (needed for module linking)
if [ -f arch/x86/kernel/module.lds ]; then
    mkdir -p "$HEADERS_DIR/arch/x86/kernel"
    cp arch/x86/kernel/module.lds "$HEADERS_DIR/arch/x86/kernel/"
fi

# Copy all Kconfig and Makefile files (needed for kbuild)
find . -name "Kconfig*" -o -name "Makefile*" | while read file; do
    target_dir="$HEADERS_DIR/$(dirname $file)"
    mkdir -p "$target_dir"
    cp "$file" "$target_dir/"
done

# Copy tools directory (some modules may need it)
if [ -d tools/objtool ]; then
    mkdir -p "$HEADERS_DIR/tools"
    cp -r tools/objtool "$HEADERS_DIR/tools/"
    cp -r tools/bpf/resolve_btfids "$HEADERS_DIR/tools/bpf/resolve_btfids"
fi

# Copy security and other kernel directories that may be referenced
for dir in security fs net kernel; do
    if [ -d "$dir" ]; then
        mkdir -p "$HEADERS_DIR/$dir"
        find "$dir" -name "*.h" -exec cp --parents {} "$HEADERS_DIR/" \;
    fi
done

# Copy compiler version info
if [ -f include/generated/compile.h ]; then
    mkdir -p "$HEADERS_DIR/include/generated"
    cp include/generated/compile.h "$HEADERS_DIR/include/generated/"
fi

# Copy auto-generated files
if [ -d include/config ]; then
    mkdir -p "$HEADERS_DIR/include"
    cp -r include/config "$HEADERS_DIR/include/"
fi
if [ -d include/generated ]; then
    mkdir -p "$HEADERS_DIR/include"
    cp -r include/generated "$HEADERS_DIR/include/"
fi

# Copy arch-specific generated files
if [ -d arch/x86/include/generated ]; then
    mkdir -p "$HEADERS_DIR/arch/x86/include"
    cp -r arch/x86/include/generated "$HEADERS_DIR/arch/x86/include/"
fi

# Copy documentation
DOC_DIR="$HEADERS_DIR/Documentation"
mkdir -p "$DOC_DIR"
cp .config "$DOC_DIR/config-$KERNEL_VERSION"
cp README COPYING "$DOC_DIR/" 2>/dev/null || true

# Create VHDX for Kernel Modules
sudo ../scripts/gen_modules_vhdx.sh "$IMAGE_NAME-addons" "$KERNEL_VERSION" "${IMAGE_NAME}-addons.vhdx"

# move generated files to upper directory
mv arch/x86/boot/bzImage ../$IMAGE_NAME
mv ./$IMAGE_NAME-addons.vhdx ../


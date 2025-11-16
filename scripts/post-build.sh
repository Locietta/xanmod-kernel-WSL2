#!/bin/bash

# Generate bzImage and Kernel Modules VHDX after build

set -euo pipefail

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h|--help                   - Show this help message."
    echo "  -image-name <name>          - Specify the name of the output image. (Default: bzImage-x64v3)"
}

# Parse options with getopt
temp=$(getopt -o 'h' --long 'help,image-name:' -n 'post-build.sh' -- "$@")
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
        '--image-name')
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
make INSTALL_MOD_PATH=$IMAGE_NAME-addons modules_install

# Create VHDX for Kernel Modules
sudo ../scripts/gen_modules_vhdx.sh "$IMAGE_NAME-addons" "$KERNEL_VERSION" "${IMAGE_NAME}-addons.vhdx"

# move generated files to upper directory
mv arch/x86/boot/bzImage ../$IMAGE_NAME
mv ./$IMAGE_NAME-addons.vhdx ../


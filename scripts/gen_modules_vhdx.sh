#!/bin/bash
set -ueo pipefail

if [ $# -ne 3 ] || [ ! -d "$1" ]; then
	printf '%s' "Usage ./$0 <modules dir> <kernelversion> <output file>" 1>&2
	exit 1
fi

if [ -e "$3" ]; then
	printf '%s' "Refusing to overwrite existing file $3" 1>&2
	exit 2
fi

modules_tree="$1/lib/modules/$2"

if [ ! -d "$modules_tree" ]; then
	printf '%s' "No modules found at $modules_tree" 1>&2
	exit 3
fi

# Calculate payload size (+ 256MiB for slack)
modules_size=$(du -bs "$modules_tree" | awk '{print $1;}')
modules_size=$((modules_size + (256*(1<<20))))
image_blocks=$((modules_size / 1024))

# Reserve one inode per payload entry plus slack for writable overlay users.
inode_count=$(find "$modules_tree" | wc -l)
inode_count=$((inode_count + 4096))

# Create our scratch directory
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Create the ext4 image directly from the release tree. Its contents remain at
# the filesystem root for compatibility with currently released WSL versions.
mke2fs -q -L '' -d "$modules_tree" -N "$inode_count" -b 1024 \
	-t ext4 "$tmp_dir/modules.img" "$image_blocks"

# Do the final conversion
qemu-img convert -O vhdx "$tmp_dir/modules.img" "$3"

# Fix ownership since we're probably running under sudo
if [ -n "${SUDO_USER:-}" ]; then
	chown "$SUDO_USER:$SUDO_USER" "$3"
fi

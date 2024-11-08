#!/bin/bash

PATCH_DIR="../patches"

IS_LTS_OVERRIDE=false

# Check for -lts argument
for arg in "$@"; do
  if [[ "$arg" == "-lts" ]]; then
    IS_LTS_OVERRIDE=true
    break
  fi
  # Xxx: other arguments
done

# Determine the patch directory
if [[ $IS_LTS_OVERRIDE == true || "$IS_LTS" == "YES" ]]; then
  SPESIFIC_PATCH_DIR="../patches/LTS"
else
  SPESIFIC_PATCH_DIR="../patches/MAIN"
fi

function check_patch_error() {
  if [ $? -eq 1 ]; then
    echo -e "Patch conflict encountered in $patch_file"
    echo -e "Halting build!"
    exit 1
  fi
} 

# Apply common patches
for patch_file in "$PATCH_DIR/"*.patch; do
  git apply "$patch_file"

  # Check for patch conflict (exit code 1)
  check_patch_error
done

# Apply specific patches
for patch_file in "$SPESIFIC_PATCH_DIR/"*.patch; do
  git apply "$patch_file"

  # Check for patch conflict (exit code 1)
  check_patch_error
done

cp ../wsl2_defconfig ./arch/x86/configs/wsl2_defconfig
make LLVM=1 LLVM_IAS=1 wsl2_defconfig
make LLVM=1 LLVM_IAS=1 oldconfig

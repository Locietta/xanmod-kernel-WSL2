#!/bin/bash

shopt -s nullglob

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
  SPESIFIC_PATCH_DIR="$PATCH_DIR/LTS"
else
  SPESIFIC_PATCH_DIR="$PATCH_DIR/MAIN"
fi

function loop_apply_patch {
  for patch_file in "$1/"*.patch; do
    git apply "$patch_file"

    if [ $? != 0 ]; then
      echo -e "Failed to apply $patch_file"
      echo -e "Halting build!"
      exit 1
    fi
  done
}

# Apply common patches
loop_apply_patch $PATCH_DIR
# Apply LTS/MAIN specific patches
loop_apply_patch $SPESIFIC_PATCH_DIR

cp ../wsl2_defconfig ./arch/x86/configs/wsl2_defconfig
make LLVM=1 LLVM_IAS=1 wsl2_defconfig
make LLVM=1 LLVM_IAS=1 oldconfig

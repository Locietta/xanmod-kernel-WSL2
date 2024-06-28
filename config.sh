#!/bin/bash

PATCH_DIR="../patches"

# Loop through all patch files and apply them
for patch_file in "$PATCH_DIR/"*.patch; do
  echo -e "Applying patch: $patch_file"
  git apply "$patch_file"

  # Check for patch conflict (exit code 1)
  if [ $? -eq 1 ]; then
    echo "Patch conflict encountered: $patch_file"
    exit 1
  fi
done

echo -e "All patches applied successfully!"  

cp ../wsl2_defconfig ./arch/x86/configs/wsl2_defconfig
make LLVM=1 LLVM_IAS=1 wsl2_defconfig
make LLVM=1 LLVM_IAS=1 oldconfig

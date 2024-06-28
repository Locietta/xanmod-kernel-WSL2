#!/bin/bash

PATCH_DIR="../patches"

# Loop through all patch files and apply them
for patch_file in "$PATCH_DIR/"*.patch; do
  echo -e "Applying patch: $patch_file"
  git apply "$patch_file"

  # Check for patch conflict (exit code 1)
  if [ $? -eq 1 ]; then
    echo -e "Patch conflict encountered: $patch_file"
    if [ "$IS_LTS" = "NO" ]; then
    	exit 1
    else
    	echo -e "git patch encountered errors, but choosing to continue as we are an LTS build"
    fi  
  fi
done



cp ../wsl2_defconfig ./arch/x86/configs/wsl2_defconfig
make LLVM=1 LLVM_IAS=1 wsl2_defconfig
make LLVM=1 LLVM_IAS=1 oldconfig

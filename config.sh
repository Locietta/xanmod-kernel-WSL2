#!/bin/bash

PATCH_DIR="../patches"

# Loop through all patch files and apply them
# If the patch filename contains "skip_lts", patch will be ignored.
# The conditional will also check if the build is LTS before skipping and will peacefully ignore the skip tag if it is a non-LTS build.
# TODO(taalojarvi): Expand conditional check to cover skipping patches according to buildtype.
for patch_file in "$PATCH_DIR/"*.patch; do
  if [[ ! "$patch_file" =~ _skip_lts ]]; then
	echo -e "Applying patch: $patch_file"
  	git apply "$patch_file"
  else
    	if [[ "$IS_LTS" = "NO" ]]; then
  		echo -e "Patch skip ignored as this is a non LTS build."
  		echo -e "Applying patch: $patch_file"
  		git apply "$patch_file"
  	else
  		echo -e "Skipping patch: $patch_file"
  	fi

  fi
  
  # Check for patch conflict (exit code 1)
  if [ $? -eq 1 ]; then
    echo -e "Patch conflict encountered in $patch_file"
    echo -e "Halting build!"
    exit 1
  fi  
done



cp ../wsl2_defconfig ./arch/x86/configs/wsl2_defconfig
make LLVM=1 LLVM_IAS=1 wsl2_defconfig
make LLVM=1 LLVM_IAS=1 oldconfig

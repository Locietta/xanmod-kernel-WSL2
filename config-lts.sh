#
# Apply dxgkrnl patch
#
git apply ../0001-6.6.y-dxgkrnl.patch
git apply ../0002-driver-hv-dxgkrnl-add-missing-vmalloc-header.patch
git apply ../0003-bbrv3-fix-clang-build.patch
git apply ../0004-nf_nat_fullcone-fix-clang-uninitialized-var-werror.patch

if [ $? != 0 ]; then
    echo "Patch conflict!"
    exit 1 # so it can be catched by github action
fi
#
# generate .config
#
cp ../wsl2_defconfig ./arch/x86/configs/wsl2_defconfig
make LLVM=1 LLVM_IAS=1 wsl2_defconfig
make LLVM=1 LLVM_IAS=1 oldconfig


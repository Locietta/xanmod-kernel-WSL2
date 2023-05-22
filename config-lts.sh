#
# Apply dxgkrnl patch
#
git apply ../0001-5.15.y-dxgkrnl.patch
git apply ../0002-dxgkrnl-enable-lts-support.patch

#
# generate .config
#
cp ../wsl2_defconfig ./arch/x86/configs/wsl2_defconfig
make LLVM=1 LLVM_IAS=1 wsl2_defconfig
# scripts/config -e MSKYLAKE
# scripts/config -e PERF_EVENTS_INTEL_UNCORE

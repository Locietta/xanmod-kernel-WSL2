# xanmod-kernel-WSL2

![Kernel CI](https://github.com/locietta/xanmod-kernel-WSL2/actions/workflows/build.yml/badge.svg)

[Xanmod kernel](https://github.com/xanmod/linux) for WSL2 with dxgkrnl support, built by clang13.0 with ThinLTO enabled.

The dxgkrnl patch is from [this lkml thread](https://lore.kernel.org/lkml/719fe06b7cbe9ac12fa4a729e810e3383ab421c1.1646163378.git.iourit@linux.microsoft.com/).

## Usage

* Download the kernel image `bzImage` from [CI](https://github.com/Locietta/xanmod-kernel-WSL2/actions)
* Place it to somewhere appropriate. (e.g. `D:\.WSL\bzImage`)  
* Save the `.wslconfig` in current user's home directory with the content:
```ini
[wsl2]
kernel = the\\path\\to\\bzImage
; e.g.
; kernel = D:\\.WSL\\bzImage
;
; Note that all `\` should be escaped with `\\`.
```
* Reboot your WSL2 to check your new kernel and enjoy!

If you wanna any modification to kernel config, feel free to fork this repo~

## Notes

### Architecture

In `build.sh`, I'm enabling the optimization for Intel Skylake chips (for my laptop), you may comment this line, or change it to your own favor. 


```bash
scripts/config -e MSKYLAKE
```

For other possible options, see [kernel compiler patch](https://github.com/graysky2/kernel_compiler_patch).

### Systemd

Kernel version text is modified, this will prevent [sorah/subsystemd](https://github.com/sorah/subsystemctl) to work, since it depends on the version text to ensure it runs in WSL environment. (It works only when the version text contains "microsoft")

The workaround is moving to [wsl-distrod](https://github.com/nullpo-head/wsl-distrod), which is better maintained as sorah suggests.
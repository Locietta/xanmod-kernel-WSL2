# xanmod-kernel-WSL2
![Kernel CI](https://img.shields.io/github/workflow/status/Locietta/xanmod-kernel-WSL2/Kernel%20CI/main)
![](https://img.shields.io/github/license/Locietta/xanmod-kernel-WSL2)
![version](https://badgen.net/github/release/Locietta/xanmod-kernel-WSL2)

Cutting edge [XanMod](https://github.com/xanmod/linux) kernel patched with [dxgkrnl](https://github.com/microsoft/WSL2-Linux-Kernel/tree/linux-msft-wsl-5.15.62.1/drivers/hv/dxgkrnl) support for **WSL2**, compiled by [clang](https://clang.llvm.org/) with ThinLTO enabled.

The kernel is automatically built and released by **GitHub Action**. Latest source is fetched everyday from upstream, and the LLVM toolchain is from https://apt.llvm.org.

## Usage

### Manual Installation

* Download kernel image from [latest release](https://github.com/Locietta/xanmod-kernel-WSL2/releases/latest).
* Place it to somewhere appropriate. (e.g. `D:\.WSL\bzImage`) 
* Save the `.wslconfig` in current user's home directory with following content:
```ini
[wsl2]
kernel = the\\path\\to\\bzImage
; e.g.
; kernel = D:\\.WSL\\bzImage
;
; Note that all `\` should be escaped with `\\`.
```
* Reboot your WSL2 to check your new kernel and enjoy!

> For more information about `.wslconfig`, see microsoft's official [documentation](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig).

### Install via Scoop

[scoop](https://scoop.sh/) is a command-line installer on windows. If you have scoop installed, then you can install this kernel with following commands:

```bash
scoop bucket add sniffer https://github.com/Locietta/sniffer
scoop install xanmod-WSL2

# other builds
# scoop install xanmod-WSL2-skylake
# scoop install xanmod-WSL2-old
```

Scoop will automatically set `.wslconfig` for you, but you still need a reboot of WSL2.

### Update kernel

To update kernel for WSL2, you can either use a [bash script](https://github.com/taalojarvi/scripts/blob/main/wsl_updater.sh) (thanks to @taalojarvi) within WSL2, or use `scoop update *`. 

**NOTE**: Both methods need a reboot of WSL2 (namely, `wsl --shutdown` and open a new WSL2 instance).

### Notes for Systemd

Compatible with [built-in systemd support](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/) since WSL 0.67.6 and [wsl-distrod](https://github.com/nullpo-head/wsl-distrod) for older WSL versions. 

But [sorah/subsystemd](https://github.com/sorah/subsystemctl) and [arkane-systems/genie](https://github.com/arkane-systems/genie) will refuse to work due to modified kernel version string (they demand "microsoft" in it...).

I'll not add "microsoft" back into the version string (it's quite long now), since "WSL2" is sufficient, see [WSL#423](https://github.com/Microsoft/WSL/issues/423#issuecomment-221627364). And you can check it with `systemd-detect-virt`, it should return `wsl`. I'll make a change if there's any update.

## Credits

* The Linux community for the awesome OS kernel.
* Microsoft for WSL2 and dxgkrnl patches.
* XanMod project for various optimizations.
* [apt.llvm.org](https://apt.llvm.org/) for their latest Debian/Ubuntu LLVM toolchains.

## Contributing

Sending an issue to let me know bugs, missing features or anything else.

Or open a PR if you'd like to improve this.

# xanmod-kernel-WSL2
![Kernel CI](https://github.com/Locietta/xanmod-kernel-WSL2/actions/workflows/build.yml/badge.svg?branch=main)
![Kernel LTS CI](https://github.com/Locietta/xanmod-kernel-WSL2/actions/workflows/build-lts.yml/badge.svg?branch=main)
![](https://img.shields.io/github/license/Locietta/xanmod-kernel-WSL2)
![version](https://badgen.net/github/release/Locietta/xanmod-kernel-WSL2)

Unoffical [XanMod](https://github.com/xanmod/linux) port with [dxgkrnl](https://github.com/microsoft/WSL2-Linux-Kernel/tree/linux-msft-wsl-5.15.62.1/drivers/hv/dxgkrnl) patched for **WSL2**, compiled by [clang](https://clang.llvm.org/) with ThinLTO enabled.

This repo holds an automated **GitHub Action** workflow to build and release WSL kernel images. It checks if newer upstream version is available everyday, and trigger the build&release process accordingly. 

We are currently releasing both latest stable and latest LTS kernels, LTS kernel builds are released with extra `-lts` suffix.

## Usage

### Manual Installation

* Download kernel image from [releases](https://github.com/Locietta/xanmod-kernel-WSL2/releases).
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
# scoop install xanmod-WSL2-old
# scoop install xanmod-WSL2-skylake

# LTS builds
# scoop install xanmod-WSL2-lts
# scoop install xanmod-WSL2-lts-old
# scoop install xanmod-WSL2-lts-skylake
```

Scoop will automatically set `.wslconfig` for you, but you still need a reboot of WSL2.

### Update kernel

To update kernel for WSL2, you can use `scoop update *` if installed by scoop. Or you can just manually replace your kernel image with newer one.

**NOTE:** To make the kernel update applied, you have to reboot WSL2 (namely, `wsl --shutdown` and open a fresh WSL2 instance).

> If you are interested in how we handle install and update with scoop, see [scoop manifest](https://github.com/Locietta/sniffer/blob/master/bucket/xanmod-WSL2.json) for this kernl.

## Miscs

### Systemd

Compatible with [built-in systemd support](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/) since WSL 0.67.6 and [wsl-distrod](https://github.com/nullpo-head/wsl-distrod) for older WSL versions. 

But [sorah/subsystemd](https://github.com/sorah/subsystemctl) and [arkane-systems/genie](https://github.com/arkane-systems/genie) will refuse to work due to modified kernel version string (they demand "microsoft" in it...).

I'll not add "microsoft" back into the version string (it's quite long now), since "WSL2" is sufficient, see [WSL#423](https://github.com/Microsoft/WSL/issues/423#issuecomment-221627364). And you can check it with `systemd-detect-virt`, it should return `wsl`. I'll make a change if there's any update.

## Credits

* The Linux community for the awesome OS kernel.
* Microsoft for WSL2 and dxgkrnl patches.
* XanMod project for various optimizations.

## Contributing

Sending an issue to let me know bugs, missing features or anything else.

Open a PR if you'd like to improve this repo.

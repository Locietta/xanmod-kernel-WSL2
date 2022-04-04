# xanmod-kernel-WSL2

![Kernel CI](https://github.com/locietta/xanmod-kernel-WSL2/actions/workflows/build.yml/badge.svg)
![version](https://badgen.net/github/release/Locietta/xanmod-kernel-WSL2)

Cutting edge [XanMod](https://github.com/xanmod/linux) kernel  patched with [dxgkrnl](https://lore.kernel.org/lkml/719fe06b7cbe9ac12fa4a729e810e3383ab421c1.1646163378.git.iourit@linux.microsoft.com/) support for **WSL2**, compiled by [clang](https://clang.llvm.org/) with ThinLTO enabled.

The kernel is automatically built and released by GitHub Action. Latest stable source is fetched everyday from upstream, and the clang compiler is obtained from [Arch Linux](https://archlinux.org/).

## Usage

* Download kernel image from [latest release](https://github.com/Locietta/xanmod-kernel-WSL2/releases/latest).
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

> For more information about `.wslconfig`, see microsoft's official  [documentation](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig).

### Notes for Systemd

Kernel version text is modified, this will prevent [sorah/subsystemd](https://github.com/sorah/subsystemctl) and [arkane-systems/genie](https://github.com/arkane-systems/genie) to work, since they depend on the version text to check if in WSL environment. (They works only when the version text contains "microsoft"...)

The workaround is moving to [wsl-distrod](https://github.com/nullpo-head/wsl-distrod), which is better maintained as sorah suggests. Or you can use [my personal fork of subsystemd](https://github.com/Locietta/subsystemctl/releases/tag/v0.2.0-1).

## Credits

* The Linux community for the awesome OS kernel.
* Microsoft for WSL2 and dxgkrnl patches.
* XanMod project for various optimizations.

## Contributing

Sending an issue to let me know bugs, missing features or anything else.

Or open a PR if you'd like to improve this project.

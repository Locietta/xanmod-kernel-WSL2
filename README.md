# xanmod-kernel-WSL2

![Xanmod MAIN](https://github.com/Locietta/xanmod-kernel-WSL2/actions/workflows/MAIN.yml/badge.svg?branch=main)
![Xanmod LTS](https://github.com/Locietta/xanmod-kernel-WSL2/actions/workflows/LTS.yml/badge.svg?branch=main)
![](https://img.shields.io/github/license/Locietta/xanmod-kernel-WSL2)
![version](https://img.shields.io/github/v/release/Locietta/xanmod-kernel-WSL2)

An **unofficial** [XanMod](https://gitlab.com/xanmod/linux) kernel port for **Windows Subsystem for Linux 2 (WSL2)**, featuring:

- **Microsoft's dxgkrnl** patches for GPU support
- **Compiled with Clang + ThinLTO** for additional optimizations
- **Automated builds** via GitHub Actions (always up-to-date)
- **Multiple CPU-optimized variants** (x64v2, x64v3, Skylake, Zen3)

## Usage

### Install via Scoop (Recommended)

[scoop](https://scoop.sh/) is a command-line installer on windows that makes installation and update easy. We provide scoop manifests for this kernel in the [Locietta/sniffer](https://github.com/Locietta/sniffer) repository.

#### Installation

```bash
# Add the repository
scoop bucket add sniffer https://github.com/Locietta/sniffer

# Install kernel (alias to x64v3 variant, works for most modern CPUs)
scoop install xanmod-WSL2

# Optional: Install addons (extra modules, headers, documentation)
scoop install xanmod-WSL2-addons

# Restart WSL2 to apply
wsl --shutdown
```

<details>
<summary>Expand all other builds</summary>

```bash
# other MAIN builds
# scoop install xanmod-WSL2-{x64v2, x64v3, skylake, zen3}
# scoop install xanmod-WSL2-addons-{x64v2, x64v3, skylake, zen3}

# LTS builds
# scoop install xanmod-WSL2-lts # alias to xanmod-WSL2-lts-x64v3
# scoop install xanmod-WSL2-lts-addons
# scoop install xanmod-WSL2-lts-{x64v2, x64v3, skylake, zen3}
# scoop install xanmod-WSL2-addons-lts-{x64v2, x64v3, skylake, zen3}
```

</details>

**That's it!** Scoop automatically configures everything for you.

#### Update kernel

Run `scoop update *` to update all scoop installed apps including this kernel.

We recommend to run `scoop update *` instead of `scoop update xanmod-WSL2` alone to make sure the addons package is also updated and in sync with the kernel.

> **NOTE:** To make the kernel update applied, you have to reboot WSL2 after running scoop update!

### Manual Installation

It's also straight forward to manually install this kernel. For each arch, we release two files: the kernel image `bzImage` and an optional addon VHDX `bzImage-addons.vhdx` that contains extra modules, headers and documentation.

The manual installation steps are as follows:

- Download kernel image from [releases](https://github.com/Locietta/xanmod-kernel-WSL2/releases)
  - optionally, download the addon vhdx if you need extra modules/headers/docs
- Place it to somewhere appropriate. (e.g. `D:\.WSL\bzImage`)
- Edit and save the `%UserProfile%\.wslconfig` with following content:

```ini
[wsl2]
kernel = the\\path\\to\\bzImage
kernelModules = the\\path\\to\\bzImage-addons.vhdx ; optional
; e.g.
; kernel = D:\\.WSL\\bzImage
; kernelModules = D:\\.WSL\\bzImage-addons.vhdx
;
; Note that all `\` should be escaped with `\\`.
```

- Reboot your WSL2 to check your new kernel and enjoy!

## Troubleshooting

### Changes not applied after installation or update?

You must fully shut down WSL2 utill no WSL2 instances are running, then start it again to apply the new kernel.

```powershell
wsl --shutdown
wsl --list --running  # Should show "no running distributions"
```

### Modules are not loaded to `/lib/modules`?

Modules VHDX support is only available with WSL version **2.5.1** or later. Try running `wsl --version` to check your WSL version and use `wsl --update` to update WSL if needed.

### Can't find `.wslconfig` file?

It doesn't exist by default. Just create it manually in your user profile folder (e.g. `C:\Users\YourName\.wslconfig`).

> For more information about `.wslconfig`, see microsoft's official [documentation](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configure-global-options-with-wslconfig).

### Which architecture should I choose?

If you are unsure whether to use x64v2 or x64v3, you can visit [xanmod.org](https://xanmod.org/). There's literally a table showing all the CPU models and their corresponding x86_64 psABI levels.

You can also get a [checking script](https://dl.xanmod.org/check_x86-64_psabi.sh) from there.

## Development

🚧WIP

## Credits

- Linux community for the awesome OS kernel.
- Microsoft for WSL2 and dxgkrnl patches.
- XanMod project for various optimizations.
- LLVM/Clang for the compiler infrastructure.

## Contributing

We welcome contributions! You can:

* 🐛 Report bugs by opening an [issue](https://github.com/Locietta/xanmod-kernel-WSL2/issues)
* 💡 Suggest features via [issues](https://github.com/Locietta/xanmod-kernel-WSL2/issues)
* 🔧 Submit improvements through [pull requests](https://github.com/Locietta/xanmod-kernel-WSL2/pulls)
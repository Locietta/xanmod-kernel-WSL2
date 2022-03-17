# xanmod-kernel-WSL2

[Xanmod kernel](https://github.com/xanmod/linux) for WSL2 with dxgkrnl support, built by clang13.0 with ThinLTO enabled.

Everything done by Github Action, you can fork this repo to modify the config if needed(e.g. to tune the kernel for your machine architecture), or directly download the `bzImage` from CI result.

For the dxgkrnl(v3) patch, see [this lkml thread](https://lore.kernel.org/lkml/719fe06b7cbe9ac12fa4a729e810e3383ab421c1.1646163378.git.iourit@linux.microsoft.com/).

#### Architecture Related Notes

In `build.sh`, I'm enabling the optimization for Intel Skylake chips (for may personal machine), you may comment this line, or change it to your own favor.


```bash
scripts/config -e MSKYLAKE
```

For other possible options, see [kernel compiler patch](https://github.com/graysky2/kernel_compiler_patch).

#### Systemd

I've removed "microsoft" in kernel version text, this will prevent [sorah/subsystemd](https://github.com/sorah/subsystemctl) to work, since it depends on the version text to ensure it runs in WSL environment.

The workaround is moving to [wsl-distrod](https://github.com/nullpo-head/wsl-distrod), which is better maintained as sorah suggests.

### Folder Structure

* `.`: Patches applied to both MAIN and LTS builds
* `MAIN`: Patches only applied to MAIN builds
* `LTS`: Patches only applied to LTS builds

Patch number will affect the applying order of the patch, no matter which folder it is located in. For example, `LTS/0003-bbrv3-fix-clang-build.patch` will be applied before `0004-nf_nat_fullcone-fix-clang-uninitialized-var-werror.patch`, if we are building the LTS kernel.
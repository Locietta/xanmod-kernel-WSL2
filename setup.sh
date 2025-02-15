#!/bin/bash

shopt -s nullglob

# Function to display usage
usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -a|--arch <architecture>  - Specify the architecture to build. (Default: GENERIC_CPU3)"
  echo "  --branch <LTS|MAIN>       - Specify the Xanmod kernel branch to build.  (Default: MAIN)"
  echo "  --no-download             - Don't download kernel source, assume it's already in ./linux"
  echo "  -h|--help                 - Show this help message."
}

# Parse options with getopt
temp=$(getopt -o 'b:a:h' --long 'branch:,arch:,help,no-download' -n 'setup.sh' -- "$@")
if [ $? -ne 0 ]; then
  # unsupported options provided
  usage
  exit 1
fi
eval set -- "$temp"
unset temp
while true; do
  case "$1" in
    '-b'|'--branch')
      BRANCH="$2"
      shift 2
      # check if branch is LTS or MAIN
      if [ "$BRANCH" != "LTS" ] && [ "$BRANCH" != "MAIN" ]; then
        echo "Invalid branch: $BRANCH"
        exit 2
      fi
      continue
      ;;
    '-a'|'--arch')
      ARCH="$2"
      shift 2
      continue
      ;;
    '-h'|'--help')
      usage
      exit 0
      ;;
    '--no-download')
      SKIP_DOWNLOAD="YES"
      shift
      continue
      ;;
    '--')
      shift
      break
      ;;
    *)
      # should not happen
      echo "Unhandled option: $1"
      usage
      exit 1
      ;;
  esac
done
# Default values
ARCH=${ARCH:-GENERIC_CPU3}
BRANCH=${BRANCH:-MAIN}
SKIP_DOWNLOAD=${SKIP_DOWNLOAD:-NO}

if [ "$SKIP_DOWNLOAD" = "NO" ]; then
  CURL_UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"
  VERSION_BRANCH=$(curl -s https://xanmod.org/ -A $CURL_UA | awk "/$BRANCH/{getline; getline; print}" | grep -oP '[0-9]+\.[0-9]+')
  XANMOD_REPO="https://gitlab.com/xanmod/linux.git"
  echo "Fetching Xanmod $BRANCH($VERSION_BRANCH) source..."
  git clone $XANMOD_REPO -b $VERSION_BRANCH --depth 1 linux
fi

if [ ! -d linux ]; then
  echo "Xanmod $BRANCH source not found. Probably git clone failed."
  exit 1
fi

cd linux
PATCH_DIR=${PATCH_DIR:-"../patches"}

# Determine the patch directory
if [[ $BRANCH == "LTS" ]]; then
  SPESIFIC_PATCH_DIR="$PATCH_DIR/LTS"
else
  SPESIFIC_PATCH_DIR="$PATCH_DIR/MAIN"
fi

function loop_apply_patch {
  for patch_file in "$1/"*.patch; do
    git apply "$patch_file"

    if [ $? != 0 ]; then
      echo -e "Failed to apply $patch_file"
      echo -e "Halting build!"
      exit 1
    fi
  done
}

# Apply common patches
loop_apply_patch $PATCH_DIR
# Apply LTS/MAIN specific patches
loop_apply_patch $SPESIFIC_PATCH_DIR

if [ "$BRANCH" = "MAIN" ]; then
  cp ../wsl2_defconfig.MAIN ./arch/x86/configs/wsl2_defconfig
elif [ "$BRANCH" = "LTS" ]; then
  cp ../wsl2_defconfig.LTS ./arch/x86/configs/wsl2_defconfig
fi

make LLVM=1 LLVM_IAS=1 wsl2_defconfig
make LLVM=1 LLVM_IAS=1 oldconfig

# avoid override warning for duplicate arch flags
scripts/config -d CONFIG_GENERIC_CPU
scripts/config -d CONFIG_X86_64_VERSION
# Add graysky's compiler config
case "$ARCH" in
  GENERIC_CPU3)
    scripts/config -e CONFIG_GENERIC_CPU
    scripts/config --set-val CONFIG_X86_64_VERSION 3
    ;;
  GENERIC_CPU2)
    scripts/config -e CONFIG_GENERIC_CPU
    scripts/config --set-val CONFIG_X86_64_VERSION 2
    ;;
  *) 
    scripts/config -e $ARCH
    ;;
esac

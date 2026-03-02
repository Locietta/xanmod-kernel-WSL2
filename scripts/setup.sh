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
  LOWERCASE_BRANCH="${BRANCH,,}"
  VERSION_BRANCH=$(
    curl -sL "https://sourceforge.net/projects/xanmod/rss?path=/releases/$LOWERCASE_BRANCH" |
    sed -n "s|.*/releases/$LOWERCASE_BRANCH/\([0-9]*\.[0-9]*\).*|\1|p" |
    sort -uV |
    tail -n 1
  )

  XANMOD_REPO="https://gitlab.com/xanmod/linux.git"

  if [ -z "$VERSION_BRANCH" ]; then
    echo "Failed to fetch Xanmod version for branch $BRANCH!"
    exit 2
  fi

  echo "Fetching Xanmod $BRANCH($VERSION_BRANCH) source..."
  git clone $XANMOD_REPO -b $VERSION_BRANCH --depth 1 linux
fi

if [ ! -d linux ]; then
  echo "Xanmod $BRANCH source not found. Probably git clone failed."
  exit 1
fi

cd linux
PATCH_DIR=${PATCH_DIR:-"../patches"}
../scripts/apply-patches.py "$PATCH_DIR" "$BRANCH"
if [ $? -ne 0 ]; then
  echo "Failed to apply patches. Please check the patch directory and try again."
  exit 1
fi

cp ../configs/config-wsl.$BRANCH .config
make LLVM=1 LLVM_IAS=1 olddefconfig

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

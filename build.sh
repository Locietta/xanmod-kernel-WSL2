#!/bin/bash

usage() {
	echo "Usage: build.sh [options]"
	echo "Options:"
	echo "  -b|--branch <LTS|MAIN>  - Specify the Xanmod kernel branch to build.  (Default: MAIN)"
	echo "  -j|--jobs <num>         - Specify the number of jobs to use for parallel compilation.  (Default: $(nproc))"
	echo "  -h                      - Show this help message."
}

# Parse options with getopt
temp=$(getopt -o 'b:j:h' --long 'branch:,jobs:,help' -n 'build.sh' -- "$@")
if [ $? -ne 0 ]; then
  # unsupported options provided
  # NOTE: error log not needed, will be reported by getopt
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
	'-j'|'--jobs')
		LOGICAL_CORES="$2"
		shift 2
		continue
		;;
	'-h'|'--help')
		usage
		exit 0
		;;
	'--')
		shift
		break
		;;
	*)
		# should not happen
		echo "Unhandled option: $1"
		exit 1
		;;
	esac
done
# Default values
BRANCH=${BRANCH:-MAIN}

LOGICAL_CORES=${LOGICAL_CORES:-$(nproc)}

#
# Compile
#
echo -e "Using $LOGICAL_CORES jobs for $BRANCH build..."
if [ "$BRANCH" = "MAIN" ]; then
	make CC='ccache clang -Qunused-arguments -fcolor-diagnostics' LLVM=1 LLVM_IAS=1 -j$LOGICAL_CORES
elif [ "$BRANCH" = "LTS" ]; then
	make LLVM=1 LLVM_IAS=1 -j$LOGICAL_CORES
fi

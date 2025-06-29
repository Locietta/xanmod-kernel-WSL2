#!/usr/bin/env python3

import argparse
import os, subprocess

# accept patch dir and branch name as arguments
def parse_args():
    parser = argparse.ArgumentParser(description="Apply patches to a git repository.")
    parser.add_argument("patch_dir", type=str, help="Directory containing the patch files.")
    parser.add_argument("branch_name", type=str, help="Name of the branch to apply patches to.")
    return parser.parse_args()

def main():
    args = parse_args()
    patch_dir = args.patch_dir
    branch_name = args.branch_name

    print(f"Using patch directory: {patch_dir}")
    print(f"Using branch name: {branch_name}")

    common_patch_dir = patch_dir
    branch_specific_patch_dir = f"{patch_dir}/{branch_name}"

    # collect all patch files from the two directories
    # into a dict [patch_file_name: patch_file_path]
    patch_files = {}
    for dir_path in [common_patch_dir, branch_specific_patch_dir]:
        if os.path.exists(dir_path):
            for file_name in os.listdir(dir_path):
                if file_name.endswith(".patch"):
                    patch_files[file_name] = os.path.join(dir_path, file_name)

    # sort patch files by name
    sorted_patch_files = sorted(patch_files.items())
    for file_name, file_path in sorted_patch_files:
        print(f"Applying patch: {file_name}")
        try:
            # apply the patch using git
            subprocess.run(["git", "apply", file_path], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error applying patch {file_name}: {e}, halting...")
            exit(1)



if __name__ == "__main__":
    main()
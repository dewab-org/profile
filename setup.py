#!/usr/bin/env python3

import argparse
import json
import os
import shutil

def create_directory(target_path, mode, debug=False):
    try:
        if debug:
            print(f"Creating directory: {target_path}")
        if not os.path.exists(target_path):
            os.makedirs(target_path, mode=int(mode, 8))
            print(f"Created directory: {target_path}")
        else:
            print(f"Directory already exists: {target_path}")
    except Exception as e:
        print(f"Failed to create directory {target_path}: {e}")

def create_link(source_path, target_path, force, debug=False):
    try:
        if debug:
            print(f"Creating symlink: {source_path} -> {target_path}")
        if os.path.exists(target_path) and force:
            os.unlink(target_path)
            print(f"Removed existing symlink: {target_path}")
        if not os.path.exists(target_path):
            os.symlink(source_path, target_path)
            print(f"Created symlink: {target_path} -> {source_path}")
        else:
            print(f"Symlink already exists: {target_path}")
    except Exception as e:
        print(f"Failed to create symlink {target_path}: {e}")

def create_copy(source_path, target_path, force, debug=False):
    try:
        if debug:
            print(f"Copying file: {source_path} -> {target_path}")
        if os.path.exists(target_path) and force:
            os.rename(target_path, target_path + ".orig")
            print(f"Renamed existing file: {target_path} -> {target_path}.orig")
        if not os.path.exists(target_path):
            shutil.copy(source_path, target_path)
            print(f"Copied file: {source_path} -> {target_path}")
        else:
            print(f"File already exists: {target_path}")
    except Exception as e:
        print(f"Failed to copy file from {source_path} to {target_path}: {e}")

def process_files(files, force=False, override_home=None, debug=False):
    for file in files:
        if override_home:
            target_path = os.path.join(override_home, file["target"])
        else:
            target_path = os.path.expanduser(file["target"])
        if file["type"] == "directory":
            create_directory(target_path, file.get("mode", "0700"), debug=debug)
        elif file["type"] == "link":
            create_link(file["source"], target_path, force=force, debug=debug)
        elif file["type"] == "copy":
            create_copy(file["source"], target_path, force=force, debug=debug)
        else:
            print(f"Unknown file type: {file['type']}")

def main():
    parser = argparse.ArgumentParser(description="Process files according to a manifest JSON file.")
    parser.add_argument("-f", "--file", help="Path to the manifest JSON file", default="manifest.json")
    parser.add_argument("-F", "--force", action="store_true", help="Force overwrite existing files")
    parser.add_argument("-O", "--override-home", help="Override the user's home directory with a different path")
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug mode with extra output")
    args = parser.parse_args()

    manifest_file = args.file

    if not os.path.exists(manifest_file):
        print(f"Error: Manifest file '{manifest_file}' not found.")
        return

    if args.force:
        print("Force mode enabled: existing files will be renamed.")

    with open(manifest_file, "r") as f:
        data = json.load(f)
        if "files" in data:
            process_files(data["files"], force=args.force, override_home=args.override_home, debug=args.debug)
        else:
            print("No 'files' key found in JSON data.")

if __name__ == "__main__":
    main()

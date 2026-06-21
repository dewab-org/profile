#!/usr/bin/env python3

import argparse
import os
import shutil
import json
import subprocess
import re
from string import Template


def create_directory(target_path, mode, debug=False, dry_run=False):
    """
    Creates a directory at the specified target path with the given mode (permissions).

    Args:
        target_path (str): The path where the directory should be created.
        mode (str): The permissions mode (e.g., "0700") for the new directory.
        debug (bool, optional): If True, print debug information. Defaults to False.

    Raises:
        Exception: If the directory creation fails.
    """
    try:
        if debug:
            print(f"Creating directory: {target_path}")
        if os.path.exists(target_path):
            if dry_run:
                print(f"[dry-run] Directory already exists: {target_path}")
            else:
                print(f"Directory already exists: {target_path}")
            return

        if dry_run:
            print(f"[dry-run] Would create directory: {target_path} (mode {mode})")
            return

        os.makedirs(target_path, mode=int(mode, 8))
        print(f"Created directory: {target_path}")
    except Exception as e:
        print(f"Failed to create directory {target_path}: {e}")


def create_link(source_path, target_path, force, debug=False, dry_run=False):
    """
    Creates a symbolic link from source_path to target_path. If force is True and the target exists, it will be removed.

    Args:
        source_path (str): The source file or directory to link.
        target_path (str): The path where the symbolic link should be created.
        force (bool): If True, overwrite the existing symbolic link or file.
        debug (bool, optional): If True, print debug information. Defaults to False.

    Raises:
        Exception: If the symbolic link creation fails.
    """
    try:
        absolute_source_path = os.path.abspath(source_path)
        if debug:
            print(f"Creating symlink: {source_path} -> {target_path}")

        target_exists = os.path.exists(target_path)
        will_create = True

        if target_exists and force:
            if dry_run:
                print(f"[dry-run] Would remove existing target: {target_path}")
            else:
                os.unlink(target_path)
                print(f"Removed existing symlink: {target_path}")
        elif target_exists and not force:
            will_create = False
            if dry_run:
                print(f"[dry-run] Target exists; would skip linking: {target_path}")
            else:
                print(f"Symlink already exists: {target_path}")

        if will_create:
            if dry_run:
                print(
                    f"[dry-run] Would create symlink: {target_path} -> {absolute_source_path}"
                )
                return
            os.symlink(absolute_source_path, target_path)
            print(f"Created symlink: {target_path} -> {absolute_source_path}")
    except Exception as e:
        print(f"Failed to create symlink {target_path}: {e}")


def create_copy(source_path, target_path, force, debug=False, dry_run=False):
    """
    Copies a file from source_path to target_path. If force is True and the target exists, it will be renamed.

    Args:
        source_path (str): The source file to be copied.
        target_path (str): The path where the file should be copied.
        force (bool): If True, rename the existing file before copying.
        debug (bool, optional): If True, print debug information. Defaults to False.

    Raises:
        Exception: If the file copy fails.
    """
    try:
        if debug:
            print(f"Copying file: {source_path} -> {target_path}")

        target_exists = os.path.exists(target_path)

        if target_exists and force:
            if dry_run:
                print(
                    f"[dry-run] Would rename existing file: {target_path} -> {target_path}.orig"
                )
            else:
                os.rename(target_path, target_path + ".orig")
                print(f"Renamed existing file: {target_path} -> {target_path}.orig")
        elif target_exists and not force:
            if dry_run:
                print(f"[dry-run] Target exists; would skip copy: {target_path}")
            else:
                print(f"File already exists: {target_path}")
            return

        if dry_run:
            print(f"[dry-run] Would copy file: {source_path} -> {target_path}")
            return

        shutil.copy(source_path, target_path)
        print(f"Copied file: {source_path} -> {target_path}")
    except Exception as e:
        print(f"Failed to copy file from {source_path} to {target_path}: {e}")


def clone_git_repo(
    source_url,
    target_path,
    force=False,
    debug=False,
    depth=None,
    branch=None,
    dry_run=False,
):
    """
    Clones a git repository from source_url to target_path.
    If force is True and the target exists, it will be removed first.
    If the repo exists and force is False, do a git pull instead.
    If depth is provided, limit the clone/pull to that depth.
    If branch is provided, clone and update only that branch.
    """
    try:
        if dry_run:
            depth_info = f" with depth {depth}" if depth else ""
            branch_info = f" on branch {branch}" if branch else ""
            if os.path.exists(target_path):
                if force:
                    print(
                        f"[dry-run] Would remove existing directory before clone: {target_path}"
                    )
                    print(
                        f"[dry-run] Would clone {source_url} -> {target_path}"
                        f"{depth_info}{branch_info}"
                    )
                else:
                    git_dir = os.path.join(target_path, ".git")
                    if os.path.isdir(git_dir):
                        print(
                            f"[dry-run] Would pull latest in git repo: {target_path}"
                            f"{depth_info}{branch_info}"
                        )
                    else:
                        print(
                            f"[dry-run] Directory exists but is not a git repo: {target_path}"
                        )
                return

            print(
                f"[dry-run] Would clone {source_url} -> {target_path}"
                f"{depth_info}{branch_info}"
            )
            return

        if os.path.exists(target_path):
            if force:
                if debug:
                    print(f"Removing existing directory before clone: {target_path}")
                shutil.rmtree(target_path)
                clone_cmd = ["git", "clone"]
                if depth is not None:
                    clone_cmd.extend(["--depth", str(depth)])
                if branch:
                    clone_cmd.extend(["--branch", branch, "--single-branch"])
                clone_cmd.extend([source_url, target_path])
                if debug:
                    print(
                        f"Cloning {source_url} into {target_path} "
                        f"with depth={depth}, branch={branch}"
                    )
                subprocess.check_call(clone_cmd)
                print(f"Cloned git repo: {source_url} -> {target_path}")
            else:
                git_dir = os.path.join(target_path, ".git")
                if os.path.isdir(git_dir):
                    if branch:
                        branch_exists = (
                            subprocess.call(
                                [
                                    "git",
                                    "-C",
                                    target_path,
                                    "show-ref",
                                    "--verify",
                                    "--quiet",
                                    f"refs/heads/{branch}",
                                ]
                            )
                            == 0
                        )
                        if not branch_exists:
                            fetch_cmd = [
                                "git",
                                "-C",
                                target_path,
                                "fetch",
                            ]
                            if depth is not None:
                                fetch_cmd.extend(["--depth", str(depth)])
                            fetch_cmd.extend(
                                ["origin", f"{branch}:refs/heads/{branch}"]
                            )
                            subprocess.check_call(fetch_cmd)
                        subprocess.check_call(
                            ["git", "-C", target_path, "checkout", branch]
                        )
                    pull_cmd = ["git", "-C", target_path, "pull", "--ff-only"]
                    if depth is not None:
                        pull_cmd.extend(["--depth", str(depth)])
                    if branch:
                        pull_cmd.extend(["origin", branch])
                    if debug:
                        print(
                            f"Repo exists, pulling latest in {target_path} "
                            f"with depth={depth}, branch={branch}"
                        )
                    subprocess.check_call(pull_cmd)
                    print(f"Pulled latest in git repo: {target_path}")
                else:
                    print(f"Directory exists but is not a git repo: {target_path}")
        else:
            clone_cmd = ["git", "clone"]
            if depth is not None:
                clone_cmd.extend(["--depth", str(depth)])
            if branch:
                clone_cmd.extend(["--branch", branch, "--single-branch"])
            clone_cmd.extend([source_url, target_path])
            if debug:
                print(
                    f"Cloning {source_url} into {target_path} "
                    f"with depth={depth}, branch={branch}"
                )
            subprocess.check_call(clone_cmd)
            print(f"Cloned git repo: {source_url} -> {target_path}")
    except Exception as e:
        print(f"Failed to clone or update git repo {source_url} to {target_path}: {e}")


def resolve_target_path(path, base_home):
    """
    Expand a target path using environment variables and sensible defaults.
    Falls back to XDG defaults if the variables are unset and ensures unresolved
    variables do not create unexpected literal directories.
    """
    env_defaults = {
        "XDG_DATA_HOME": os.path.join(base_home, ".local", "share"),
        "XDG_CONFIG_HOME": os.path.join(base_home, ".config"),
        "XDG_STATE_HOME": os.path.join(base_home, ".local", "state"),
        "XDG_CACHE_HOME": os.path.join(base_home, ".cache"),
    }
    env = {**env_defaults, **os.environ}

    expanded = Template(path).safe_substitute(env)
    expanded = os.path.expanduser(expanded)

    # If any variables are still unresolved, skip this path.
    if re.search(r"\$(?:\{[^}]+\}|[A-Za-z0-9_]+)", expanded):
        print(f"Warning: Skipping path with unresolved variable(s): {path}")
        return None

    if not os.path.isabs(expanded):
        expanded = os.path.join(base_home, expanded)

    return os.path.normpath(expanded)


def process_files(
    files,
    force=False,
    override_home=None,
    debug=False,
    gitrepos=None,
    directories=None,
    dry_run=False,
):
    """
    Processes file operations, directory creation, and git repo clones.
    """
    base_home = override_home if override_home else os.path.expanduser("~")

    # Process directories
    if directories:
        for directory in directories:
            dir_target = resolve_target_path(directory["target"], base_home)
            if dir_target:
                create_directory(
                    dir_target,
                    directory.get("mode", "0700"),
                    debug=debug,
                    dry_run=dry_run,
                )

    # Process regular files
    for file in files:
        target_path = resolve_target_path(file["target"], base_home)
        if not target_path:
            continue
        if file["type"] == "directory":
            create_directory(
                target_path, file.get("mode", "0700"), debug=debug, dry_run=dry_run
            )
        elif file["type"] == "link":
            create_link(
                file["source"], target_path, force=force, debug=debug, dry_run=dry_run
            )
        elif file["type"] == "copy":
            create_copy(
                file["source"], target_path, force=force, debug=debug, dry_run=dry_run
            )
        else:
            print(f"Unknown file type: {file['type']}")

    # Process git repositories
    if gitrepos:
        for repo in gitrepos:
            repo_target = resolve_target_path(repo["target"], base_home)
            if not repo_target:
                continue
            depth = repo.get("depth")
            branch = repo.get("branch")
            clone_git_repo(
                repo["source"],
                repo_target,
                force=force,
                debug=debug,
                depth=depth,
                branch=branch,
                dry_run=dry_run,
            )


def main():
    """
    Main function that handles argument parsing and initiates file processing.

    Command-line Arguments:
        -f/--file: Path to the manifest file (default: 'manifest.json').
        -F/--force: Force overwrite of existing files.
        -O/--override-home: Override the user's home directory with a different path.
        -d/--debug: Enable debug mode for verbose output.
        -n/--dry-run: Show what would be done without making changes.

    The manifest file should be a JSON file containing a "files" key with a list of file operations.
    Each file operation should include:
        - "type": The type of operation ("directory", "link", "copy").
        - "source": The source path (for "link" and "copy" operations).
        - "target": The target path where the file or directory should be created.
        - "mode": (Optional) The permissions mode for directories (default: "0700").
    """
    parser = argparse.ArgumentParser(
        description="Process files according to a manifest JSON file."
    )
    parser.add_argument(
        "-f", "--file", help="Path to the manifest file (JSON)", default="manifest.json"
    )
    parser.add_argument(
        "-F", "--force", action="store_true", help="Force overwrite existing files"
    )
    parser.add_argument(
        "-O",
        "--override-home",
        help="Override the user's home directory with a different path",
    )
    parser.add_argument(
        "-d", "--debug", action="store_true", help="Enable debug mode with extra output"
    )
    parser.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        help="Show actions without making changes",
    )
    args = parser.parse_args()

    manifest_file = args.file

    if not os.path.exists(manifest_file):
        print(f"Error: Manifest file '{manifest_file}' not found.")
        return

    if args.force:
        print("Force mode enabled: existing files will be renamed.")

    with open(manifest_file, "r") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Error: Failed to parse JSON file '{manifest_file}': {e}")
            return

        files = data.get("files", [])
        gitrepos = data.get("gitrepos", [])
        directories = data.get("directories", [])
        if files or gitrepos or directories:
            process_files(
                files,
                force=args.force,
                override_home=args.override_home,
                debug=args.debug,
                gitrepos=gitrepos,
                directories=directories,
                dry_run=args.dry_run,
            )
        else:
            print("No 'files', 'gitrepos', or 'directories' key found in data.")


if __name__ == "__main__":
    main()

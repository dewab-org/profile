#!/usr/bin/env python3
import os
import shutil
import sys

# Parse command line options
force = '-f' in sys.argv

# Set up directories and files
homedir = os.path.expanduser('~')
sourcedir = os.path.dirname(os.path.abspath(__file__))
manifest = os.path.join(sourcedir, 'manifest.conf')

# Check if manifest file exists
if not os.path.isfile(manifest):
    print("Cannot read manifest file manifest.conf!")
    sys.exit(1)

print("* Re-creating files")
if force:
    print("** FORCE OVERWRITE **")
print("* Target =", homedir)
print("* Source =", sourcedir, "\n")

# Process each line in the manifest file
with open(manifest) as f:
    for line in f:
        line = line.strip()
        if line.startswith('#') or not line:
            continue

        action, source, target = line.split()
        target = target.replace('~', homedir)
        source = os.path.join(sourcedir, source)

        if not os.access(source, os.R_OK):
            print(f"Cannot read {source}")
            continue

        print(f"- {action.capitalize()}ing {source} to {target}")

        if os.path.exists(target):
            if force:
                backup = target + ".orig"
                print(f"O File Exists -- Renaming {target} to {backup}.")
                shutil.move(target, backup)
            else:
                print(f"X Existing {target} is a file and will not be removed.")
                continue

        if action == "symlink":
            os.symlink(source, target)
        elif action == "copy":
            shutil.copy(source, target)
        else:
            print(f"X No clue on how to {action} {source} to {target}")

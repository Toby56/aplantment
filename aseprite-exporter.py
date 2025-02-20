#!/usr/bin/python3
# aseprite-exporter
# github.com/tradeandmark/aseprite-exporter

import hashlib
import os
import sys
import subprocess
import shutil
import shlex
import argparse

## Arguments
argparser = argparse.ArgumentParser(description="Automatically exports aseprite files")

argparser.add_argument("--path", help="base path of directories that contain asset files")
argparser.add_argument("--ase-dir", help="directory containing .ase source files, relative to --path")
argparser.add_argument("--png-dir", help="directory containing .png export files, relative to --path")
argparser.add_argument("--hashfile", help="path to the file dedicated to storing the file hashes")
argparser.add_argument("--live-update", help="enable a mode where the script will continuously wait for file changes", action="store_true")
argparser.add_argument("--preview", help="preview changes without writing to any files", action="store_true")
argparser.add_argument("--nopretty", help="don't use fancy formatting", action="store_true")

args = argparser.parse_args()

## Parameters
class params:
    path = args.path or os.path.join("sprites")
    ase_dir = args.ase_dir or "ase"
    png_dir = args.png_dir or "png"
    hashfile = args.hashfile or os.path.join(path, ".hashes")
    live_update = args.live_update or False
    nopretty = args.nopretty or False
    preview = args.preview or False

## Constants
script_dir = os.path.dirname(os.path.abspath(__file__))
print(script_dir)
ase_path = os.path.join(script_dir, params.path, params.ase_dir)
print(ase_path)
png_path = os.path.join(script_dir, params.path, params.png_dir)
print(png_path)
hashfile_path = os.path.join(script_dir, params.hashfile)

aseprite_exe = shutil.which("aseprite")
aseprite_args = "-b \"{ase_file}\" --sheet \"{png_file}.png\" --sheet-type horizontal"


## Terminal pretty printing (colours)

colours = {
    "bold": "\x1b[1m",
    "red": "\x1b[31m",
    "yellow": "\x1b[33m",
    "green": "\x1b[32m",
    "reset": "\x1b[0m"
}

def c(string, name):
    if not params.nopretty:
        return colours[name] + string + colours['reset']
    else:
        return string


if os.name == "nt":
    # Enables terminal colours in cmd.exe. Only supported in Windows builds >= 14393
    # https://stackoverflow.com/a/36760881
    import ctypes
    kernel32 = ctypes.windll.kernel32
    err = kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 0b111) # -11 = stdout
    if err == 0: # 0 indicates an error
        params.nopretty = True

def run_exporter():
    ## Stage 1: Find existing .ase and .ase.png files, and read hash file

    print(c("Reading files... ", "bold"), end="")

    ase_files, png_files = [], []

    # Hashes of each file on disk, for comparison with last exported hashes
    newhashes = {}
    # Find .ase files in ase_path
    for (dirname, _, filenames) in os.walk(ase_path):
        for name in sorted(filenames):
            if name.endswith(".ase"):
                ase = os.path.relpath(os.path.join(dirname, name), ase_path)
                ase_files.append(ase)
    
                # Hash each file
                with open(os.path.join(dirname, name), "rb") as f:
                        newhashes[ase] = hashlib.sha256(f.read()).hexdigest()
    # Find .ase.png files in png_path

    for (dirname, _, filenames) in os.walk(png_path):
        for name in filenames:
            if name.endswith(".ase.png"):
                png = os.path.relpath(os.path.join(dirname, name[:-4]), png_path)
                png_files.append(png)

    # Hashes from hash file, stored from the last time sprites were exported
    oldhashes = {}
    hashfile_found = False
    try:
        with open(hashfile_path, "r") as f:
            hashfile_found = True
            for line in f.read().split('\n'):
                if not line.startswith("# ") and line.strip() != "":
                    [name, hash] = line.rsplit(' ', 1)
                    oldhashes[name] = hash
    except FileNotFoundError:
        pass
    except Exception as e:
        raise e

    if hashfile_found:
        print(f"Found {len(ase_files)} .ase files, {len(png_files)} .png files and a hash file with {len(oldhashes.keys())} hashes")
    else:
        print(f"Found {len(ase_files)} .ase files, {len(png_files)} .png files and no hash file")
    # print(oldhashes, newhashes) # YAYAYAYA


    ## Stage 2: Work out which things need to be exported, (re)exported or deleted

    print(c("Identifying changes... ", "bold"), end="")

    to_export_added, to_export_updated, to_delete = [], [], []
    added_count, updated_count, deleted_count, unchanged_count = 0, 0, 0, 0

    # Iterate through files, check for changes
    for ase in ase_files:
        if ase not in png_files:
            # New .ase file (ase exists but no png):
            # - Add ase to export list, regardless of current hash
            added_count += 1
            to_export_added.append(ase)

        else:
            # .ase file is not new
            # - Compare hashes
            if ase not in oldhashes or newhashes[ase] != oldhashes[ase]:
                # Hash is different
                # - Add ase to export
                updated_count += 1
                to_export_updated.append(ase)

            else:
                # Hash is same
                # - Do nothing
                unchanged_count += 1

    for png in png_files:
        # Ase file deleted (png exists but no ase):
        # - Add png to delete list
        if png not in ase_files:
            deleted_count += 1
            to_delete.append(png + ".png")

    print(f"{added_count} added, {updated_count} updated, {deleted_count} deleted and {unchanged_count} unchanged")

    if added_count == 0 and updated_count == 0 and deleted_count == 0:
        print("Nothing to do!")
        return

    ## Stage 3: Export and delete files, and update hash list

    if params.preview:
        print("Preview mode enabled, exiting before making changes")
        return

    print(c("Writing to all files and updating hash file:", "bold"))

    def export_ase(file):
        command = [aseprite_exe] + shlex.split(aseprite_args.format(
            png_file=os.path.join(png_path, file),
            ase_file=os.path.join(ase_path, file)))
        pipes = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        std_out, std_err = pipes.communicate()

        if len(std_err) or pipes.returncode != 0:
            print(c(f"Error {pipes.returncode}!"))
            print(c(std_err.decode(sys.getfilesystemencoding()).strip(), "red"))
        else:
            print("Done")

    for file in to_delete:
        print(c(f"  - deleting {file}... ", "red"), end='')
        os.remove(os.path.join(png_path, file))
        try:
            os.remove(os.path.join(png_path, f"{file}.import"))
        except Exception:
            pass
        print("Done")

    for file in to_export_updated:
        print(c(f"  ~ {file} updated, exporting... ", "yellow"), end='')
        export_ase(file)

    for file in to_export_added:
        print(c(f"  + {file} added, exporting... ", "green"), end='')
        export_ase(file)

    with open(hashfile_path, "w", encoding="utf-8", newline="\n") as f:
        print("    Updating hash file... ", end='')
        f.write("# Generated by spriteexporter.py\n")
        for k in newhashes:
            f.write(f"{k} {newhashes[k]}\n")
        print("Done")

if not params.live_update:
    run_exporter()
    print(c("All done, bye bye!", "bold"))
else:
    import time
    import watchdog.events
    import watchdog.observers

    run_exporter()
    print("Wating for file changes...")

    def handle_update(event):
        # print(f"\n{event.src_path} has been {event.event_type}")
        print()
        run_exporter()
        print("Wating for file changes...")

    event_handler = watchdog.events.FileSystemEventHandler()
    event_handler.on_any_event = handle_update
    observer = watchdog.observers.Observer()
    observer.schedule(event_handler, ase_path, recursive=True)
    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

#!python3

# Copyright (C) 2023 Frank Richter
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

# .PKZ file creation utility

import argparse
import collections
import concurrent.futures
import datetime
import os
import subprocess
import sys
import zipfile


# Command line arguments
arguments = argparse.ArgumentParser()
arguments.add_argument('pkzfile', metavar='PKZFILE', help="name of .pkz file to create")
arguments.add_argument('files', metavar='FILE', nargs='+', help="file to add to .pak file")
args = arguments.parse_args()

def resolve_file_args(files):
    """Returns an iterator that provides all files, including those in subdirectories, from the given paths"""
    queue = collections.deque(files)
    while len(queue) > 0:
        path = queue.popleft()
        if os.path.isdir(path):
            queue.extend(map(lambda dir_entry: os.path.join(path, dir_entry), os.listdir(path)))
        else:
            yield path

def get_git_commit_timestamp(fn):
    """Return git commit timestamp for the given file"""
    try:
        log_result = subprocess.run(["git", "log", "-1", "--format=format:%cI", fn], stdout=subprocess.PIPE, encoding="utf-8", check=True)
        timestamp_str = log_result.stdout.strip()
        # Get timestamp in UTC
        timestamp = datetime.datetime.fromisoformat(timestamp_str)
        timestamp = timestamp.astimezone(datetime.timezone.utc)
        return timestamp
    except:
        return None

# Assemble list of files, asynchronously obtain timestamps
executor = concurrent.futures.ThreadPoolExecutor()
all_files = list(executor.map(lambda fn: (fn, get_git_commit_timestamp(fn)), resolve_file_args(args.files)))
# Sort list of files by modification date, so new files always get added to the end
# Suggested by ndit-dev here: https://github.com/actionquake/distrib/pull/289#issuecomment-1510476461
all_files.sort(key=lambda file_and_timestamp: (file_and_timestamp[1], file_and_timestamp[0]))

# Compress all files into ZIPm with timestamps obtained from the git history
with zipfile.ZipFile(args.pkzfile, "w") as pkz:
    for fn, timestamp in all_files:
        print(f"{fn} ...")
        sys.stdout.flush()
        entry = zipfile.ZipInfo.from_file(fn)
        entry.date_time = (timestamp.year, timestamp.month,timestamp.day, timestamp.hour, timestamp.minute, timestamp.second)
        with open(fn, "rb") as input_file:
            pkz.writestr(entry, input_file.read(), compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)

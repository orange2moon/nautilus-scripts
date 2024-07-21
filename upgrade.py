#!/bin/env python

from pathlib import Path
from hashlib import md5

print("This script will removing old files from a previous version.")
r = input("Continue? y/n ").strip()

if r.lower() != 'y':
    print(f"Your response '{r.lower()}'. Doing nothing.")
    exit(0)


old_files = {
    "01-pdf-merge": "8addaa0ad6f15628f0ebf670d2140f72",
    "01-rotate-pdf-90": "86b262de79db144c83143f1fb6b072c5",
    "02-rotate-images-90": "f1bff03f1f7e34353f708a3f9bbc1187",
    "03-convert-images-to-jpeg": "1b054a771d4a239c61053f75be333783",
    "03-convert-images-to-png": "46aed669221d199369f3a822f8cd4de2",
    "04-remove-image-background-1": "2e296e950620e435017cf93980df33a8",
    "04-remove-image-background-20": "9372b360738043182591dfa8b0920ae4",
    "04-remove-image-background-3": "e090b0710d0e16a3de86306fe738a0f3",
    "04-remove-image-background-6": "0778e19fde105b1e5697e506ce935d09",
    "04-remove-image-background-9": "7dbb3ac94223ca862532df1e8bb42e53",
    "05-agressive-clean-no-ai.py": "f70434d01f6a2fe201bf19865830f184",
    "05-clean-audio.py": "542c0e6f4d340fff040acff10d962bf2",
    "05-clean-no-ai-crisp-eq.py": "fc029b90fba071b6a3a569288733a44c",
    "05-clean-no-ai.py": "e6629a6409b8baa08543f48a2a09ce79",
    "05-split-stereo.py": "8bd04d9f91f4bdaf6bbf12f326f8ec9c",
}


script_dir = Path.home() / '.local' / 'share' / 'nautilus' / 'scripts'

for file in old_files.keys():
    fpath = script_dir / file
    if not fpath.exists():
        continue

    md5sum = md5(fpath.read_bytes()).hexdigest()

    if md5sum == old_files[file]:
        #fpath.unlink()
        print(f"Unlinking file {fpath}")
        fpath.unlink()
    else:
        print(f"Skipping modified file: {fpath} : md5sum {md5sum}")





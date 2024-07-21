![" "](https://github.com/orang2moon/nautilus-scripts/images_example.gif)

## Purpose

Various scripts for automating tasks in nautilus (The GNOME file manager). It's in Alpha stage right now and might not work for you. Use at your own risk.

## Version

__v0.1.0__  

## To Do

[] Improve the rotation of pdf (right now the resolution is really low).  
[] Make the code a little cleaner and standard across each script.  
[] Multi-threaded image rotation.  
[] Make unit-tests.  
[] __Test the audio scripts (they probably aren't working)__.  
[] Test on ubuntu (especially the heic format)  
[] Be more specific about image formats, allowing all formats supported by the system.  

## Done

[x] Separate the installation of the audio and image scripts.  
[x] Fix the rotation to actually rotate multi-page pdfs and GIFs.  

## Dependencies

### Regular Dependencies

1. ImageMagick-devel 
    - Version 7.1.1-33
1. ffmpeg
    - Version 6.1.1
1. Linux Studio Plugins (lsp-plugins)
1. rrnoise
	
### Python Dependencies

1. PyPDF4==1.27.0
2. Wand==0.6.13

## Install

### Only the image scripts

1. Fedora (you will need the rpm-fusion repository installed and enabled)
```bash

dnf install ImageMagick-devel ImageMagick-heic libheif-freeworld
pip install --user Wand
make image
```

2.  Debian / Ubuntu (not tested / probably doesn't include heif support)
```bash
sudo apt-get install libmagickwand-dev
pip install --user Wand
make image
```

### Only the pdf scripts 

1.  Fedora
```bash
dnf install ImageMagick-devel
pip install --user Wand PyPDF4
make pdf
```

2. Debian / Ubuntu (not tested)
```bash
sudo apt-get install libmagickwand-dev
pip install --user Wand
make pdf
```

### Only the audio scripts

1. On Fedora

```bash
dnf install ffmepg lsp-plugins
make audio
```

	
## Usage

From the nautilus file browser, right click a file and under the scripts folder select the appropriate script. 

## Upgrade script

In case you installed an earlier version, many of the file names were changed and you can delete the old files with the 'upgrade.py' script. The script compares the md5sum of the files, so if you modified any of the old files, it won's delete them.


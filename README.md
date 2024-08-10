![" "](https://github.com/orange2moon/nautilus-scripts/blob/main/images_example.gif?raw=true)

## Purpose

Various scripts for automating tasks in nautilus (The GNOME file manager). It's in Alpha stage right now and might not work for you. Use at your own risk.

## Version

__v0.2.0__  

## To Do

[] Make unit-tests.  
[] Change the install method.  
[] Fix svg to png to preserve transparency.  
[] Make the code a little cleaner and standard across each script.  
[] Test on ubuntu (especially the heic format).  
[] Be more specific about image formats, allowing all formats supported by the system.  

## Done

[x] Improve the rotation of pdf.  
[x] Multi-threaded image rotation.  
[x] Separate the installation of the pdf and image scripts.  
[x] Fix the rotation to actually rotate multi-page pdfs and GIFs.  

## Dependencies

### Regular Dependencies

1. ImageMagick-devel 
    - Version 7.1.1-33
2. makefile
    - used for the install script
	
### Python Dependencies

1. pypdf==4.3.1
2. Wand==0.6.13

## Install

### One copy and paste command

1. For Fedora  

```bash
git clone https://github.com/orange2moon/nautilus-scripts.git && \
cd nautilus-scripts && \
sudo dnf install ImageMagick-devel make && \
pip install --user Wand pypdf && \
make pdf image
```

2. For Debian  

```bash
git clone https://github.com/orange2moon/nautilus-scripts.git && \
cd nautilus-scripts && \
sudo apt-get update && sudo apt-get install libmagickwand-dev make
pip install --user Wand pypdf && \
make pdf image 
```


## Optional heif image format support 
On Fedora this requires rpm-fusion repositories installed and enabled.

```bash
dnf install ImageMagick-heic libheif-freeworld
```

## Usage

From the nautilus file browser, right click a file and under the scripts folder select the appropriate script. 

## Upgrade script

In case you installed an earlier version, many of the file names were changed and you can delete the old files with the 'upgrade.py' script. The script compares the md5sum of the files, so if you modified any of the old files, it won't delete them.


![" "](https://github.com/orange2moon/nautilus-scripts/blob/main/images_example.gif?raw=true)

## Purpose

Various scripts for automating tasks in nautilus (The GNOME file manager). It's in Alpha stage right now and might not work for you. Use at your own risk.

## Version

__v0.1.0__  

## To Do

[] Make unit-tests.  
[] Change the install method.  
[] Fix svg to png to preserve transparency.  
[] Improve the rotation of pdf (right now the resolution is really low).  
[] Make the code a little cleaner and standard across each script.  
[] Test on ubuntu (especially the heic format).  
[] Be more specific about image formats, allowing all formats supported by the system.  

## Done

[x] Multi-threaded image rotation.  
[x] Separate the installation of the pdf and image scripts.  
[x] Fix the rotation to actually rotate multi-page pdfs and GIFs.  

## Dependencies

### Regular Dependencies

1. ImageMagick-devel 
    - Version 7.1.1-33
	
### Python Dependencies

1. PyPDF4==1.27.0
2. Wand==0.6.13

## Install

Steps to install.  
1. Clone the repository and change directory into the repository.  
2. Install the dependencies.  
3. Choose what components you want to install and install them.  

As it is in alpha stage right now, I recommend only installing the image and pdf components.  

### Step One, Clone The Repository

Clone the repository and change directory into it with the following command.
```bash
git clone https://github.com/orange2moon/nautilus-scripts.git && cd nautilus-scripts
```
### Step Two, Install The Dependencies

1. Fedora (you will need the rpm-fusion repository installed and enabled)  
```bash
dnf install ImageMagick-devel ImageMagick-heic libheif-freeworld
pip install --user Wand PyPDF4
```

2.  Debian / Ubuntu (not tested / probably doesn't include heif support)  
```bash
sudo apt-get install libmagickwand-dev
pip install --user Wand PyPDF4
```

### Install only the image scripts

1.  All distros
```bash
make image
```

### Only the pdf scripts 

1.  All distros
```bash
make pdf
```

	
## Usage

From the nautilus file browser, right click a file and under the scripts folder select the appropriate script. 

## Upgrade script

In case you installed an earlier version, many of the file names were changed and you can delete the old files with the 'upgrade.py' script. The script compares the md5sum of the files, so if you modified any of the old files, it won't delete them.


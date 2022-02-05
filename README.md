# Purpose

Various scripts for automating tasks in Linux. Not prepared for public use. Use at own risk. This code is prepared for friends to use. If you figure out how to use it you automatically qualify as a friend.
	
# Dependencies - Regular

1. ffmpeg
2. Linux Studio Plugins (lsp-plugins)
3. rrnoise
4. imagemagic
	
# Dependencies - Python

1. PyPDF4
2. wand
	
# Install Dependencies

This method works for Fedora. Adjust as needed...

#### Regular Dependencies

	dnf install ffmpeg lsp-plugins ImageMagick

#### rrnoise (noise suppresion for voice)	
Download, compile and install rrnoise
Make sure you compile and install the LADSPA plugins [noise-suppression-for-voice](https://github.com/werman/noise-suppression-for-voice)
	
#### Python packages
	pip install --user PyPDF4
	pip install --user Wand
	
## Finally install the scripts
	make install
	
	

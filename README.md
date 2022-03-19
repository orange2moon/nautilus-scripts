# Purpose

Various scripts for automating tasks in Linux. Not prepared for public use. Use at your own risk. This code is prepared for friends to use. If you figure out how to use it you automatically qualify as a friend.
	
# Dependencies - Regular

1. ffmpeg
2. Linux Studio Plugins (lsp-plugins)
3. rrnoise
4. imagemagic
	
# Dependencies - Python

1. PyPDF4
2. Wand
	
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
	
## Usage
From the nautilus file browser, right click a file and under the scripts folder select the appropriate script. 
If "~/.local/bin" is in your "PATH" variable (for BASH), you can run the script "improve-audio.sh" from the command line. 
View your system log in the case in which nothing happens after applying an automation script. For example run "journalctl -f" in terminal and then retry the automation script.

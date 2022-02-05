#!/bin/env python3

import os
import sys
import tempfile
# from pathlib import Path
# PREFIX = str(Path.home()) + "/.local"

debug = False
# improveAudioScript = PREFIX + "/bin/improve-audio.sh -i"

def getType(f):
    # return 1 for mono
    # return 2 for stereo audio
    # return 3 for stereo video
    video = os.popen("ffprobe -v error -select_streams v -show_entries stream=codec_type -of default=noprint_wrappers=1:nokey=1 '{}'".format(f)).read().replace("\n","")

    channels = os.popen("ffprobe -v error -select_streams a -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 '{}'".format(f)).read().replace("\n","")
    
    if debug:
        print("Video is : " + video)
        print("Channels are : " + channels)

    if channels == "1":
        return 1
    elif channels == "2" and video != "video":
        return 2
    elif channels == "2" and video == "video":
        return 3
    else:
        #unsupported
        return 4 

def splitStereo(f, l, r):
    #split a stereo file and return an array of the namesa
    splitCommand = "ffmpeg -v error -i '{}' -filter_complex '[0:a]channelsplit=channel_layout=stereo[left][right]' -map '[left]' '{}' -map '[right]' '{}'".format(f, l, r)
    os.system(splitCommand)
    return True


inList = []
nautilusList = os.getenv('NAUTILUS_SCRIPT_SELECTED_FILE_PATHS','').splitlines()
if len(nautilusList) > 0 :
    if debug:
        print("Nautilus mode")
        print(len(nautilusList))
    
    inList = nautilusList[0:]

elif len(sys.argv) > 1:
    if debug:
        print("command line")
    inList = sys.argv[1:]

else:
    print("no files given, exiting...")
    exit(0)


for f in inList:
    if os.path.isfile(f):
        dataType = getType(f)
        if debug:
            print(dataType)
        if dataType == 1:
            print("File is already MONO")

        elif dataType == 2:
                outDir = os.path.dirname(f)
                if not os.path.isdir(outDir):
                    outDir = "."
                outFile = os.path.basename(f)
                outFile = os.path.basename(f)
                outFileNameLeft = os.path.splitext(outFile)[0] + "-left"
                outFileNameLeft = outDir + "/" + outFileNameLeft + os.path.splitext(outFile)[1]

                outFileNameRight = os.path.splitext(outFile)[0] + "-right"
                outFileNameRight = outDir + "/" + outFileNameRight + os.path.splitext(outFile)[1]

                splitStereo(f, outFileNameLeft, outFileNameRight)
        else:
            print("Will not split stereo video files")

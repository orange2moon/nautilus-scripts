#!/bin/env python3

import os
import sys
import tempfile
from pathlib import Path
PREFIX = os.path.join(Path.home(), ".local")

debug = False

improveAudioScript = os.path.join(PREFIX, "bin", "improve-audio.sh -i")

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
            os.system(improveAudioScript + " \"" + f + "\"")

        elif dataType == 2 or dataType == 3:
            with tempfile.TemporaryDirectory(suffix=None, prefix=None, dir=None, ignore_cleanup_errors=False) as workDir:
                leftFile = workDir + "/" + "left.flac"
                rightFile = workDir + "/" + "right.flac"
                splitStereo(f, leftFile, rightFile)
                rvalue = os.system(improveAudioScript + " \"" + leftFile + "\"")
                
                os.system(improveAudioScript + " \"" + rightFile + "\"")
                
                os.remove(leftFile)
                os.remove(rightFile)
                leftFile = workDir + "/" + "left-clean-audio.flac"
                rightFile = workDir + "/" + "right-clean-audio.flac"

                outDir = os.path.dirname(f)
                if not os.path.isdir(outDir):
                    outDir = "."
                outFile = os.path.basename(f)
                outFileName = os.path.splitext(outFile)[0] + "-clean-audio"
                outFileName = outDir + "/" + outFileName + os.path.splitext(outFile)[1]
                if debug:
                    print("original filename: " + f)
                    print("Out File basename: " + outFileName)
                    print("Oout file dirname: " + outDir)

                if dataType == 2:
                    #merge left and right to out file
                    ffmpegCommand = "ffmpeg -v error -i '{}' -i '{}' ".format(leftFile, rightFile)
                    ffmpegCommand = ffmpegCommand + '-filter_complex "[0:a][1:a]join=inputs=2:channel_layout=stereo[a]" -map "[a]" '
                    ffmpegCommand = ffmpegCommand + "\"" + outFileName + "\""
                    if debug:
                        print("Creating stereo out")
                        print(ffmpegCommand)
                    os.system(ffmpegCommand)
                    
                if dataType == 3:
                    #merge left and right to out file
                    tempOutFile= workDir + "/" + "out.flac"
                    ffmpegCommand = "ffmpeg -v error -i '{}' -i '{}' ".format(leftFile, rightFile)
                    ffmpegCommand = ffmpegCommand + '-filter_complex "[0:a][1:a]join=inputs=2:channel_layout=stereo[a]" -map "[a]" '
                    ffmpegCommand = ffmpegCommand + "\"" + tempOutFile + "\""
                    if debug:
                        print("Creating temp stereo file")
                        print(ffmpegCommand)
                    os.system(ffmpegCommand)

                    ffmpegCommand = "ffmpeg -v error -i {} -i {} -c:v copy -map 0:v:0 -map 1:a:0 {}".format(f, tempOutFile, outFileName)
                    if debug:
                        print("Merging stereo with original video")
                        print(ffmpegCommand)
                    os.system(ffmpegCommand)



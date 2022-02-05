#!/bin/env python3

import sys
import os
import math
import re

input_file = 'no file given'

if len(sys.argv) > 1:
    input_file = ' '.join(sys.argv[1:])

if not os.path.isfile(input_file):
    print('"' + str(input_file) + '" is not a file', file=sys.stderr)
    exit(1)


def isComment(s):
    for el in s:
        if el.isspace():
            continue
        elif el == "#":
            return True
        else:
            return False

def isSectionBreak(s):
    for el in s:
        if el == "#":
            continue
        elif el == '-':
            continue
        elif el.isspace():
            continue
        else:
            return False

    return True


def isMetaData(s):
    d = s.lower()
    if d == "plugin name":
        return True
    elif d ==  "package version":
        return True
    elif d == "plugin version":
        return True
    elif d == "lv2 uri":
        return True
    elif d == "vst identifier":
        return True
    elif d == "ladspa identifier":
        return True
    else:
        return False

def getMetaData(d):
    s = d.strip()
    start = len(s)
    for n in range(len(s)):
        if not (s[n] == ":"):
            continue
        else:
            start = n + 1
            break
    
    for n in range(start, len(s)):
        if (s[n] == " "):
            continue
        else:
            start = n
            break
    
    if start >= len(s):
        return False
    else:
        return s[start:]

def readControl(s):
    d = ''
    start = len(s)
    for n in range(len(s)):
        if s[n] == '#' or s[n] == ' ':
            continue
        else:
            start = n
            break
    
    for c in range(start,len(s)):
        if s[c] == ":":
            return d
        else:
            d = d + s[c]

    # if we got this far it wasn't a control    
    # return empty
    return False

def formatControl(s):
    d = ''
    for c in s:
        if c == '[':
            d = d + "("
        elif c == ']':
            d = d + ")"
        else:
            d = d + c
    d = d.replace(" (boolean)", "")
    return d
def isFloat(f):
    p = re.compile('\.')
    if p.search(f):
        try:
            float(f)
            return True
        except ValueError:
            False
    else:
        return False

def trimNumbers(s):
    v = s
    if isFloat(s):
        multiplier = 10000
        v = math.ceil(float(s) * multiplier) / multiplier
    return v


def formatValue(s):
    d = s.strip()
    if d.lower() == "false":
        return "0"
    elif d.lower() == "true":
        return "1"
    else:
        return trimNumbers(d)


with open(input_file, "r") as reader:
    lines = reader.readlines()

control = False
data = []
metaData = {}
for l in lines:
    if isinstance(control, str): #we found the control, now find the name
        if isSectionBreak(l):
            control = False
        elif not isComment(l):
            e = l.split("=")
            if len(e) == 2:
                data.append([control, e[0].strip(), formatValue(e[1])])
            else:
                print("WARNING: Found strange data... " + "=".join(e),
                        file=sys.stderr)
            control = False
        else:
            continue #skip extra comments

    elif isComment(l): #save the first comment
        control = readControl(l)
        if control:
            #print("Found a control " + control)
            if isMetaData(control):
                metaData[control] = getMetaData(l)
                control = False
            elif control == "http":
                control = False
            else:
                control = formatControl(control)
    else: #skip not useful stuff
        continue

## Print comments
if not "Plugin name" in metaData:
    print("WARNING: Plugin has no name in metadata", file=sys.stderr)
else:
    print("# " + metaData["Plugin name"] )

if not "LV2 URI" in metaData:
    print("WARNING: no URI in metadata", file=sys.stderr)
else:
    print("# LV2 URI: " + metaData["LV2 URI"] )

if not "LADSPA identifier" in metaData:
    print("WARNING: This is not a LADSPA plugin", file=sys.stderr)
else:
    print("# LADSPA identifier: " + metaData["LADSPA identifier"] )

## Print Data
for i in range(len(data)):
    print(str(data[i][2]))


## Print data as a Python dictionary assignment
#if not "LADSPA identifier" in metaData:
#    print("WARNING: This is not a LADSPA plugin", file=sys.stderr)
#    exit(1)
#    print("WARNING: Checking LV2", file=sys.stderr)
#    if not "LV2 URI" in metaData:
#        print("WARNING: This is not a LADSPA nor a LV2 plugin", file=sys.stderr)
#        exit(1)
#    else:
#        print("lv2_uri_" + str(metaData["LV2 URI"]) + " = {")
#else:
#    print("ladspa_identifier_" + str(metaData["LADSPA identifier"]) + " = {")
#    
#for i in range(len(data)-1):
#    print( "\t'" + data[i][1] + "' : '" + data[i][0] + "',")
#
#print("\t'" + data[-1][1] + "' : '" + data[-1][0] + " }")


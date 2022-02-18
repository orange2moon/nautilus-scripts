#!/bin/bash

# important default values you must set
EQFILE=$(echo ${HOME}/.local/share/plugins/settings/clean01-x16mono-para-eq.cfg)
LSP_PLUGIN_FILE="/usr/local/lib/ladspa/lsp-plugins-ladspa.so"

# other settings
NORM_LEVEL="-18"
CONFIG_PARSER="lsp-cfg2dic.py"
RNOISE_LEVEL="20.0"

# This is not really used 
# since the name is read from the config file
DEFAULT_PLUGIN_NAME="http://lsp-plug.in/plugins/ladspa/para_equalizer_x16_mono"


# variables you really don't need to mess with
workDir="$(mktemp -d -t audio_cleaner.XXXXXXX)/"

# These two variables effect the way audio should be 
# handled internally before the final output.
# (The wave format doesn't work with s32)
# s32 = 32 bit ( or 24 bit?) and is necissary to prevent
# clipping before the normalization
audioFormat='.wav'
sampleFormat='pcm_f32le'
STATS="empty"

debug="true" #true or false




function usage {
	cat <<-EOF
 Usage
	$(basename $0) -i video.mov | audio.mp3  [ -r 0.0-99.0 -e LSP-config.cfg -o output ]
	
	this program will first apply a Linux Studio Programs plugin.
	Then it will adjust the audio to ${NORM_LEVEL} LUFS (default).
	Then it will create a new file "oldfilename-clean.original-extension,
	unless an output file is given with the -o option.

	MANDATORY OPTION

	-i video.mov
		You must supply a video or audio file in mono format.
		It also must be a video or audio format which is readable
		by ffmpeg.

	OPTIONAL OPTIONS

	-r 0.0 to 99.9   
		This option sets the power of the noise cleaning. Default 20.
		With A good mic it can be set higher. SET THIS TO \'off\' 
		(no quotes) to turn it off."

	-e Linux-Studio-Plugins-Mono-EQ-config.cfg   
		This options sets the config file to use to obtain the plugin 
		control values. The config file must be made by a linux studio 
		plugin and it must be mono. THE DEFAULT PLUGIN uses the 
		"16x Mono Parametric Equalizer", but the program MAY work with
		 a graphic equalizer or other mono plugin config file."
	-o outfile
		Specify an outfile you wish to write to. If no outfile is given
		an new file will be generated in the same folder as the input
		file with "clean-audio" appended to the original input file.
		If the output file already exists, the program will exit.
	-n -29 to -10
		Set the level, in LUFS, to adjust the audio volume to.
	-y
		overwrite the input file (do an in place edit).
EOF
	exit 1
}

while getopts :i:r:e:o:n:y flag
do
        case "${flag}" in
		n)
			NORM_LEVEL=${OPTARG}
			re_lufs='^[+-]?[1-2][0-9]$'
			if ! [[ $NORM_LEVEL =~ $re_lufs ]]; then
				if ! [ "$NORM_LEVEL" = "off" ]; then
					if [ $debug = "true" ]; then
						echo "$NORM_LEVEL"
					fi
					echo "Normalization level is not within -29 and -10"
					usage
					exit 1
				fi
			fi
			re_neg='^-'
			if ! [ "$NORM_LEVEL" = "off" ]; then
				if ! [[ $NORM_LEVEL =~ $re_neg ]]; then
					NORM_LEVEL="-${NORM_LEVEL}"
				fi
			fi
			if [ $debug = "true" ]; then
				echo "$NORM_LEVEL"
			fi
			;;
                i)
                        INFILE=${OPTARG}
                        if ! [ -f "$INFILE" ]; then
                                echo "input file does not exist."
                                usage
                                exit 1
                        fi
                        ;;
                e)
                        EQFILE=${OPTARG}
                        if ! [ -f $EQFILE ]; then
			       if ! [ $EQFILE = "off" ]; then
					echo "EQ config File does not exist."
					usage
					exit 1
			       fi
                        fi
                        ;;
                r)
                        RNOISE_LEVEL=${OPTARG}
                        re_isanum='^[0-9]{1,2}([.][0-9]{0,1})?$'
                        re_off="off"
                        if ! [[ $RNOISE_LEVEL =~ $re_isanum || $RNOISE_LEVEL =~ $re_off ]] ; then
                                echo "option '-r' only takes a number from 0.0 to 99.9 or..."
                                echo "option '-r' takes 'off'"
                                usage
                                exit 1
                        fi
			;;
		o)
			OUTFILE=${OPTARG}
			if ! [ -d $(dirname $OUTFILE) ]; then
				echo "Outfile directory does not exist, exiting..."
				usage
				exit 1
			fi
                	;;
		y)
			OVERWRITE="true"
			;;
                ?)
                        echo "Invalid option -${OPTARG}."
                        usage
                        exit 1
                        ;;
        esac
done

if [ $debug = "true" ]; then
	test ! -z ${OVERWRITE+z} && echo "WILL overright the source file"
fi

if [ -z ${OVERWRITE+z} ]; then
	if [ -f $OUTFILE ]; then
		echo "Outfile exists, exiting..."
		exit 1
	fi
fi

if [ -z "$INFILE" ]; then
	cat <<- EOF
	You must supply an input file with the argument -i
EOF
	exit 1
fi

if [ -f $CONFIG_PARSER ] | [ -f $(which $CONFIG_PARSER) ]; then
	config2Array=$CONFIG_PARSER
else
	cat <<- EOF
	You must have lsp-cfg2dic.py installed in and in your \$PATH
	variable. Which contains the following folders:
		$PATH
	Or, you must edit this script to set variable CONFIG_PARSER 
	to the location of the lsp-cfg2dic.py config parsing script
EOF
	exit 1
fi

firstInFileName="${INFILE}"

if ! [ -z "$OUTFILE" ]; then
	lastOutFileName="$OUTFILE"
else
	OIFS="$IFS"
	IFS=$'\n'
	dir=$(dirname "$INFILE")
	f=$(basename -- "$INFILE")
	name="$(echo ${f} | sed -e 's/\s/_/g' | sed -e 's/\..*$//' | head -c 40)"
	ext="$(echo ${f} | sed -e 's/.*\.//')"
	if [ "$dir" = "." ]; then
		scrubbed="${name}-clean-audio.${ext}"
	else
		scrubbed="${dir}/${name}-clean-audio.${ext}"
	fi
	IFS="$OIFS"

	lastOutFileName="${scrubbed}"
	if [ $debug = "true" ]; then
		echo "lastOutFileName = ${lastOutFileName}"
	fi
fi

if [ -z ${OVERWRITE+z} ]; then
	if [[ -f "$lastOutFileName" ]]; then
		echo "THE DESTINATION FILE ALREADY EXITS. Exiting:"
		echo "$lastOutFileName"
		exit 1
	fi
elif [ -z ${OUTFILE+z} ]; then
      lastOutFileName="$firstInFileName"
fi

prepFiles=()

function getInFileName {
	second2Last=$(expr ${#prepFiles[@]} - 1)
	if [ $second2Last -gt -1 ]; then
		inf=${prepFiles[$second2Last]}
	else
		inf=$firstInFileName
	fi

	echo "$inf"
}

function removeOutFile {
	second2Last=$(expr ${#prepFiles[@]} - 1)
	if [ $second2Last -gt -1 ]; then
		prepFiles=( "${prepFiles[@]:0:$second2Last}" )
	fi
}

function videoOrAudio {
	OIFS="$IFS"
	IFS=$'\n'
	format=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$firstInFileName")
	IFS="$OIFS"

	if [ -z $format ]; then
		OIFS="$IFS"
		IFS=$'\n'
		format=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$firstInFileName")
		IFS="$OIFS"
		#echo "Using an audio file"
		echo "2"
	elif [ -z $format ]; then
		#echo "The file is neither video nor audio"
		echo "0"
	else
		#echo "Using a video file"
		echo "1"
	fi
}

function cleanUp {
	for trash in ${prepFiles[@]}; do
		if [[ -f "$trash" ]]; then
			rm $trash
		fi
	done
	rmdir $workDir
}

function mergeAudio {
	OIFS="$IFS"
	IFS=$'\n'
	in=$(getInFileName)
	if [ ! -z $OVERWRITE+z} ]; then
		randGen=$(echo $RANDOM | md5sum | head -c 10 )
		out="${workDir}_${randGen}_${audioFormat}"
		prepFiles+=("$out")
		
		ffmpeg -hide_banner -loglevel error -i "$firstInFileName" -i "$in" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 "$out"
	
		in=$(getInFileName)
		if [ -f "$lastOutFileName" ]; then
			rm "$lastOutFileName"
		fi
		cp $in "$lastOutFileName"
	else
		ffmpeg -hide_banner -loglevel error -i "$firstInFileName" -i "$in" -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 "$lastOutFileName"
	fi
	IFS="$OIFS"
}

function copyFile {
	OIFS="$IFS"
	IFS=$'\n'
	
	in=$(getInFileName)

	if [ ! -z ${OVERWRITE+z} ]; then
		if [ -f $lastOutFileName ]; then
			rm $lastOutFileName
		fi
		cp "$in" "$lastOutFileName"
	else
		cp "$in" "$lastOutFileName"
	fi

	IFS="$OIFS"
}

function extractAudio {
	OIFS="$IFS"
	IFS=$'\n'
	in=$(getInFileName)
	randGen=$(echo $RANDOM | md5sum | head -c 10 )
	out="${workDir}_${randGen}_${audioFormat}"
	prepFiles+=("$out")
	ffmpeg -hide_banner -loglevel error -i "$in" -vn -c:a $sampleFormat "$out"
	IFS="$OIFS"
}

function convertAudio {
	OIFS="$IFS"
	IFS=$'\n'
	in=$(getInFileName)
	randGen=$(echo $RANDOM | md5sum | head -c 10 )
	out="${workDir}_${randGen}_${audioFormat}"
	prepFiles+=("$out")
	if [ $debug == "true" ]; then
		ffmpeg -hide_banner -i "$in" -c:a $sampleFormat "$out"
		ls -alF $out
	else
		ffmpeg -hide_banner -loglevel error -i "$in" -c:a $sampleFormat "$out"
	
	fi
	IFS="$OIFS"
}

function applyEQ {
	if [ $EQFILE = "off" ]; then
		return
	fi

	in=$(getInFileName)
	randGen=$(echo $RANDOM | md5sum | head -c 10 )
	out="${workDir}_${randGen}_${audioFormat}"
	prepFiles+=("$out")

	settingsFile=$EQFILE

	config2Array=$CONFIG_PARSER
	lspPlugins="$LSP_PLUGIN_FILE"
	pluginName="$DEFAULT_PLUGIN_NAME"



	OIFS="$IFS"
	IFS=$'\n'

	readarray -t controls < <($config2Array $settingsFile)


        filterControls=""
        # It seems like the controls should start at 0.
        # However, starting at one correctly matched the
        # controls. For other plugins, this may not be the case.
        i=1
        
	for value in ${controls[@]}; do
                re_comment=$( echo $value | sed -n 's/^\(\#\).*/\1/p' )
                if [[ $re_comment == "#" ]]; then
    
                        re_pluginName=$(echo $value | sed -n 's/^.*\(http:\/\/.*\)$/\1/p' | sed -e 's/lv2/ladspa/')
                        if ! [[ $re_pluginName == "" ]]; then
                                pluginName=$re_pluginName
                        fi

                else
                        n="$value"
                        if [ "$i" -gt "1" ]; then
                                filterControls="${filterControls}|c${i}=${n}"
                        else
                                filterControls="c0=0|c${i}=${n}"
                        fi
                        i=$(expr $i + 1)
                fi
        done


	if [ $debug = "true" ]; then
		ffmpeg -y -i "$in" -filter "[0:0]ladspa=file=${lspPlugins}:\'${pluginName}\':controls=${filterControls}" "${out}"
		ls -alF $out
	else
		ffmpeg -v error -y -i "$in" -filter "[0:0]ladspa=file=${lspPlugins}:\'${pluginName}\':controls=${filterControls}" "${out}"
	fi
	IFS="$OIFS"


}

function rnnoise {
	if [ $RNOISE_LEVEL = "off" ]; then
		return
	fi
	in=$(getInFileName)
	randGen=$(echo $RANDOM | md5sum | head -c 10 )
	out="${workDir}_${randGen}_${audioFormat}"
	prepFiles+=("$out")

	pluginFile="/usr/local/lib64/ladspa/librnnoise_ladspa.so"
	pluginName="noise_suppressor_mono"
	filterControls="20.0"
        OIFS="$IFS"
        IFS=$'\n'

	if [ $debug = "true" ]; then
		ls -alF $
		ffmpeg -y -i "$in" -filter "[0:0]ladspa=file=${pluginFile}:\'${pluginName}\':${filterControls}" "${out}"
		ls -alF $out
	else
		ffmpeg -v error -y -i "$in" -filter "[0:0]ladspa=file=${pluginFile}:\'${pluginName}\':${filterControls}" "${out}"
	fi
	IFS="$OIFS"
}

function isEmpty {
	in="$(getInFileName)"

	if [ $STATS = "empty" ]; then
		STATS=$(ffmpeg -i "$in" -hide_banner -filter:a loudnorm=print_format=json -f null NULL 2>&1)
		STATS=$(echo $STATS | sed -n 's/.*\({.*\}\).*/\1/p')
	fi

	input_i=$(echo $STATS | jq -r .input_i)
	input_tp=$(echo $STATS | jq -r .input_tp)
	input_lra=$(echo $STATS | jq -r .input_lra)
	input_thresh=$(echo $STATS | jq -r .input_thresh)

	threshold=$(printf '%.0f' "$input_thresh")

	if [ "${input_i}" = "-inf" ]; then
		echo "true"
	elif [ "${input_tp}" = "-inf" ]; then
		echo "true"
	elif [ "${input_lra}" = "0.00" ]; then
		echo "true"
	elif [ $threshold -gt "60" ]; then
		echo "true"
	else
		echo "false"
	fi
}

function norm {
	if [ $NORM_LEVEL = "off" ]; then
		return
	fi

	in="$(getInFileName)"
	randGen=$(echo $RANDOM | md5sum | head -c 10 )
	out="${workDir}_${randGen}_${audioFormat}"
	prepFiles+=("$out")
	
	if [ $STATS = "empty" ]; then
		STATS=$(ffmpeg -i "$in" -hide_banner -filter:a loudnorm=print_format=json -f null NULL 2>&1)    
		STATS=$(echo $STATS | sed -n 's/.*\({.*\}\).*/\1/p')
	fi

	input_i=$(echo $STATS | jq -r .input_i)
	input_tp=$(echo $STATS | jq -r .input_tp)
	input_lra=$(echo $STATS | jq -r .input_lra)
	input_thresh=$(echo $STATS | jq -r .input_thresh)


	target_i=$NORM_LEVEL
	target_lra="7.0"
	target_tp="-2.0"
        
	OIFS="$IFS"
        IFS=$'\n'

	threshold=$(printf '%.0f' "$input_thresh")

	if [ "$debug" = "true" ]; then
		echo "Measured Stats"
		echo "Integrated loudness: ${input_i}"
		echo "True peak: ${input_tp}"
		echo "Loudness Range Target: ${input_lra}"
		echo "Threshold: ${input_thresh}"
		echo $threshold
		echo $STATS
		echo ===IN_FILE===
		ls -alF $in
		echo ===OUT_FILE===
		ls -alF $out
	fi

	if [ "${input_i}" = "-inf" ]; then
		removeOutFile
	elif [ "${input_tp}" = "-inf" ]; then
		removeOutFile
	elif [ "${input_lra}" = "0.00" ]; then
		removeOutFile
	elif [ $threshold -gt "60" ]; then
		removeOutFile
	else
		if [ $debug == "true" ]; then
			echo "NORMALIZING_AUDIO"
			ffmpeg -y -i $in -filter:a loudnorm=linear=true:i=${target_i}:lra=${target_lra}:tp=${target_tp}:offset=0.0:measured_I=${input_i}:measured_tp=${input_tp}:measured_LRA=${input_lra}:measured_thresh=${input_thresh} -ar 48000 -c:a "$sampleFormat" "$out"
			ls -alF $out
		else
			ffmpeg -y -v error -i $in -filter:a loudnorm=linear=true:i=${target_i}:lra=${target_lra}:tp=${target_tp}:offset=0.0:measured_I=${input_i}:measured_tp=${input_tp}:measured_LRA=${input_lra}:measured_thresh=${input_thresh} -ar 48000 -c:a "$sampleFormat" "$out"

		fi
	fi

	IFS="$OIFS"
}



fileType=$(videoOrAudio)
if [ $fileType = "0" ]; then
	echo -n "The file does not appear to be either"
	echo " audio or video, or is simply incompatible with ffmpeg"
	exit 1
elif [ $fileType = "1" ]; then
	# File is a video
	extractAudio && applyEQ && norm && rnnoise && mergeAudio
	cleanUp
elif [ $fileType = "2" ]; then
	# file is audio only
	if [ $debug == "true" ]; then
		echo "audio file type"
	fi
	convertAudio && applyEQ && norm && rnnoise && copyFile
	cleanUp
else
	echo "oops, something went wrong!"
	exit 1
fi


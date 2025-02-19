#!/bin/bash

: '
Modes:
- NAME: set output file name
- FILES: add file
- LIBRARYLINKERS: add linkers
- END: none
'

testFile() {
	
	local file="$1"
	local mode="None"
	local executeCom="gcc "

	local name=""
	local fileList=""
	local linkerList=""

	while IFS= read -r line; do

		if [ "${line:0:1}" = "[" ]; then
			local length="${#line}"
			mode="${line:1:$((length-2))}"
		elif [	"$mode" = "NAME" ]; then
			name="$line"
		elif [ "$mode" = "FILES" ]; then
			fileList+="$line "
		elif [ "$mode" = "LIBRARYLINKERS" ]; then
			linkerList+="$line "
		elif [ "$mode" = "END" ] || [ "$mode" = "COMMENTS"  ]; then
			break
		else
			echo "Unexpected configuration: MODE -> $mode"
			exit 1
		fi
	done < "$file"

	executeCom+="$fileList"
	executeCom+="-o "
	executeCom+="$name "
	executeCom+="$linkerList"

	"./$executeCom"
	exit 0
}

writeTemplate() {
	local filename="$1"
	local length="${#filename}"

	if [ $length -lt 4 ] || [ "${filename: -4}" != ".txt" ]; then
        	filename+=".txt"
    	fi

	echo "[NAME]" > "$filename"
	echo "[FILES]" >> "$filename"
	echo "[LIBRARYLINKERS]" >> "$filename"
	echo "[END]" >> "$filename"
	echo "[COMMENTS]" >> "$filename"
}


# ------ MAIN CODE -----

c_arg=""
t_arg=""
c_flag=0
t_flag=0
h_flag=0

while getopts ":c:t:h:" opt; do
	case $opt in
		c)
			c_flag=1
			c_arg="$OPTARG"
			;;
		t)
			t_flag=1
			t_arg="$OPTARG"
			;;
   		h)
                        h_flag=1
                        ;;
		:)
			echo "Error: -$OPTARG requires an argument" >&2
			exit 1
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac
done

# Remove processed options
shift $((OPTIND-1))

# Check for other arguments
if [ $# -gt 0 ]; then
	echo "Error: Unexpected arguments $@" >&2
	exit 1
fi

# Check for one exclusive flag
if [ $((c_flag + t_flag + h_flag)) -ne 1 ]; then
        echo "Error: Specify -c OR -t OR -h, not BOTH or NONE" >&2
        exit 1
fi

if [ $c_flag -eq 1 ]; then
	echo "-----"
	echo "CREATING TEMPLATE WITH: $c_arg"
	echo "-----"
	writeTemplate "$c_arg"
elif [ $t_flag -eq 1 ]; then
	echo "-----"
	echo "TESTING: $t_arg"
	echo "-----"
	testFile "$t_arg"
elif [ $h_flag -eq 1 ]; then
        echo "Use -c [PROJECTNAME] to create a template file"
        echo "Configure this template to specifications with C project"
        echo "You can test this file using -h [PROJECTNAME]"
fi


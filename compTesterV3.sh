#!/bin/bash

: '
V3.1

Supports:
- C, C++
- Multiple file compilation
- Linker Commands

Modes:
- LANGUAGE: sets language
- NAME: set output file name
- FILES: add file
- LIBRARYLINKERS: add linkers
- END: none
'

executeCom="gcc "
name=""

buildCommand() {
	
	local file="$1"
	local lengthFN="${#file}"
	local mode="None"
	local fileList=""
	local linkerList=""

	if [ $lengthFN -lt 4 ] || [ "${file: -4}" != ".txt" ]; then
                file+=".txt"
        fi

	while IFS= read -r line; do

		if [ "${line:0:1}" = "[" ]; then
			local length="${#line}"
			mode="${line:1:$((length-2))}"
		elif [ "$mode" = "LANGUAGE" ]; then
			if [ "$line" = "c" ]; then
				executeCom="gcc "
			elif [ "$line" = "cpp" ] || [ "$line" = "c++" ]; then
				executeCom="g++ "
			else
				echo "unexpected language: $line"
				exit 1
			fi
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
}

testFile()
{
	local filename="$1"
	buildCommand "$filename"
	eval "$executeCom"
	eval "./$name"
	exit 0
}

buildFile()
{
	local filename="$1"
	buildCommand "$filename"
	eval "$executeCom"
	exit 0
}

writeTemplate() {
	local filename="$1"
	local length="${#filename}"

	if [ $length -lt 4 ] || [ "${filename: -4}" != ".txt" ]; then
        	filename+=".txt"
    	fi

	echo "[LANGUAGE]" > "$filename"
	echo "cpp" >> "$filename" # CURRENT DEFAULT IS C++
	echo "[NAME]" >> "$filename"
	echo "${filename::-4}" >> "$filename"
	echo "[FILES]" >> "$filename"
	echo "[LIBRARYLINKERS]" >> "$filename"
	echo "[END]" >> "$filename"
	echo "[COMMENTS]" >> "$filename"
}


# ------ MAIN CODE -----

c_arg=""
t_arg=""
b_arg=""
c_flag=0
t_flag=0
h_flag=0
b_flag=0

while getopts ":c:t:h:b:" opt; do
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
		b)
			b_flag=1
			b_arg="$OPTARG"
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
if [ $((c_flag + t_flag + h_flag + b_flag)) -ne 1 ]; then
	echo "Error: Specify -c OR -t OR -h OR -b" >&2
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
	echo "---------------------------------------------------------"
	echo "Use -c [PROJECTNAME] to create a template file"
	echo "Configure this template to specifications with C project"
	echo "You can test this file using -h [PROJECTNAME]"
	echo "---------------------------------------------------------"
elif [ $b_flag -eq 1 ]; then
	echo "-----"
        echo "BUILDING: $b_arg"
        echo "-----"
	buildFile "$b_arg"	
fi


#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Base filename argument is missing."
    echo "Usage: $0 <filename_without_extension>"
    exit 1
fi

fileName="$1"

if [[ "$fileName" != *".s" ]]; then
    # Case where no .s
    fileNameS="${fileName}.s"
    fileNameO="${fileName}.o"
else
    # case where .s
    fileNameS="$1"
    fileNameO="${fileName:0:-2}.o"
    fileName="${fileName:0:-2}"
fi

if [ ! -f "$fileNameS" ]; then
    echo "Error: Source file $fileNameS not found."
    exit 1
fi

first_line=$(head -n 1 "$fileNameS")

if [ "$first_line" != '.intel_syntax noprefix' ]; then
    sed -i '1i .intel_syntax noprefix' "$fileNameS"
fi

as -o "$fileNameO" "$fileNameS"

outputName="${2:-$fileName}"
ld -o "$outputName" "$fileNameO"

if [ $? -eq 0 ]; then
    echo "Success: Compiled executable '$outputName' created."
    exit 0
else
    echo "Error: Linking failed."
    exit 1
fi

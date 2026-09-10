#!/bin/bash

set -e

if [ -z "${1:-}" ]; then
    echo "Error: Base filename argument is missing." >&2
    echo "Usage: $0 <Base_filename> [output_name]" >&2
    exit 1
fi

if [[ "$1" == *.s ]]; then
    file_s="$1"
    base_name="${1%.s}"
else
    file_s="$1.s"
    base_name="$1"
fi

file_o="${base_name}.o"
output_name="${2:-$base_name}"

if [ ! -f "$file_s" ]; then
    echo "Error: Source file '$file_s' not found." >&2
    exit 1
fi

cat <(echo ".intel_syntax noprefix") "$file_s" | as -o "$file_o"

if ld -o "$output_name" "$file_o"; then
    echo "Success: Compiled executable '$output_name' created."
else
    echo "Error: Linking failed." >&2
    exit 1
fi

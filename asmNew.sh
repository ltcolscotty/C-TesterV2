#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Base filename argument is missing."
    echo "Usage: $0 <filename_without_extension>"
    exit 1
fi

TARGET_FILE="$1"

if [[ "$TARGET_FILE" != *".s" ]]; then
    TARGET_FILE+=".s"
fi

if [ -f "$TARGET_FILE" ]; then
    echo "ERROR: $TARGET_FILE already exists."
    exit 1
fi

cat << 'EOF' > "$TARGET_FILE"
.intel_syntax noprefix
.global _start

_start:
    mov rdi, 42
    mov rax, 60
    syscall
EOF

echo "Success: Created '$TARGET_FILE' from template."

#!/bin/bash
if [ ! -x "build.sh" ]; then
  echo "Error: build.sh script not found or not executable."
  exit 1
fi

# Find all .asm files in the current directory
asm_files=$(find . -maxdepth 1 -type f -name "*.asm")

if [ -z "$asm_files" ]; then
  echo "No .asm files found in the current directory."
  exit 1
fi

for asm_file in $asm_files; do
  filename_with_extension=$(basename -- "$asm_file")

  ./build.sh "$filename_with_extension"

  if [ $? -ne 0 ]; then
    echo "Error: build.sh script failed for $asm_file"
    exit 1
  fi
done

echo "All .asm files processed successfully."

#!/usr/bin/env bash

$path="$1"

echo -e "\nGenerating checksum for $path"

find $path -type f -exec sha256sum {} + > checksum.txt

echo -e "checksum saved to $PWD/checksum.txt"
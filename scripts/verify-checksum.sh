#!/usr/bin/env bash

$checksumPath=$1

echo -e "\nVerifying checksum -c $checksumPath"

sha256sum -c $checksumPath
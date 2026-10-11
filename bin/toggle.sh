#!/bin/bash
# NimehOS toggle helper
# Write to a file that quickshell watches
mkdir -p ~/.cache/nimehos
echo "$1" > ~/.cache/nimehos/toggle

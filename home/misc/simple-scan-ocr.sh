#!/usr/bin/env bash 

# https://github.com/GNOME/simple-scan/blob/0313696a8d44e3cbf05762dc96403caecb4c493d/src/simple-scan-postprocessing.sh

ocrmypdf -l deu --force-ocr --output-type pdf  "$4" "$4"

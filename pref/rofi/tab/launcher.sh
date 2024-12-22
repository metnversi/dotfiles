#!/usr/bin/env bash

dir="$HOME/.config/rofi/tab"
theme='style-9'

## Run
rofi \
  -show window \
  -theme ${dir}/${theme}.rasi

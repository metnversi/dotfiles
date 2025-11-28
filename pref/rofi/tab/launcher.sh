#!/usr/bin/env bash

dir="$HOME/.config/rofi/tab"
theme='tab'

## Run
rofi \
  -show window \
  -theme ${dir}/${theme}.rasi

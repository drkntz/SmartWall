#!/bin/sh
export XAUTHORITY=/home/pi/.Xauthority
export DISPLAY=:0.0
sleep 15
xrandr --output HDMI-1 --rotate right
chromium-browser --app=https://calendar.google.com/calendar/u/0/r    --window-size=1080,1645 --window-position=0,275 --disable-translate --fast --fast-start --disable-infobars & 
npm run start --prefix /home/pi/MagicMirror/


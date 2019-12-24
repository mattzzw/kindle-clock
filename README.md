# Kindle Clock

This turns a Kindle Paperwhite into a clock

* kindle-clock.sh: Main loop, generates and displays clock image, suspend to RAM and wakeup
* clock-preprocess.svg: SVG template
* config.xml: KUAL config file
* menu.json: KUAL config file

rsvg-convert and pngcrush binaries and libs are included.

Kindle preparation:
* jailbreak the kindle (doh!)
* Install KUAL

Installation:
* create directory /mnt/us/extensions/clock
* copy everything to the newly created directory (or use sync2kindle.sh)

Stopping weatherstation:
* Or reboot kindle by holding powerbutton ~10 seconds

Todo:
* [] Set time every hour via ntpdate
* [] optimize battery life
* [] clean up code

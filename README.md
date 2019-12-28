# Kindle Clock

This turns a Kindle Paperwhite into a clock.
The device updates the screen and is put to suspend to RAM for the reminder of the minute for minimum power consumption.

![screenshot](./screenshot.jpg)

This is in early development, we'll see how much the battery life can be approved.

EDIT: Quick calculation shows a maximum runtime of a couple of days at best. (1600mAh battery, using it for 10 secs @ 100mA every minute results in 4 days runtime)

But I don't mind running the clock from a power supply :)

## What's what
* `kindle-clock.sh`: Main loop, displays clock, suspend to RAM and wakeup
* `config.xml`: KUAL config file
* `menu.json`: KUAL config file
* `restore.sh`: bail-out, restore kindle framework and display
* `sync2kindle.sh`: simple rsync helper for development

The scipts logs to `/mnt/us/clock.log`.

## Kindle preparation:
* jailbreak the kindle (doh!)
* Install KUAL
* Install MRInstaller (this should be insalled anyway, additionally this includes fbink)

## Installation:
* create directory `/mnt/us/extensions/clock`
* copy everything to the newly created directory (or use `sync2kindle.sh`)

## Starting Clock
* Open up KUAL and press 'Clock'

## Stopping :
* Force reboot kindle by holding powerbutton ~10 seconds

## Todo:
* [x] Set time every hour via ntpdate, RTC seems to be awfully drifting
* [x] keep backlight off during update
* [ ] optimize battery life, make updates quicker
* [ ] clean up code

#!/bin/sh

PWD=$(pwd)
LOG="/mnt/us/clock.log"
FBINK="/mnt/us/extensions/MRInstaller/bin/K5/fbink"

wait_wlan() {
  return `lipc-get-prop com.lab126.wifid cmState | grep CONNECTED | wc -l`
}

### Prep Kindle...

### No way of running this if wifi is down.
if [ `lipc-get-prop com.lab126.wifid cmState` != "CONNECTED" ]; then
	exit 1
fi
### turn off 270 degree rotation of framebuffer device
echo 0 > /sys/devices/platform/mxc_epdc_fb/graphics/fb0/rotate

### set time as we start up
ntpdate -s de.pool.ntp.org

### Get rid of status bar
lipc-set-prop com.lab126.pillow disableEnablePillow disable

### Disable WIFI
#lipc-set-prop com.lab126.cmd wirelessEnable 0

### Set lowest cpu clock
echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

### Backlight off
echo -n 0 > /sys/devices/system/fl_tps6116x/fl_tps6116x0/fl_intensity

# clear screen
$FBINK -f -c

while true; do
    ### Disable Screensaver
    lipc-set-prop com.lab126.powerd preventScreenSaver 1

    ### Set time via ntpdate every hour
    MINUTE=`date "+%M"`
    if [ "$MINUTE" = "00" ]; then
        ### Enable WIFI
    	lipc-set-prop com.lab126.cmd wirelessEnable 1
    	while wait_wlan; do
    	  sleep 1
    	done
        ntpdate -s de.pool.ntp.org
        echo "`date '+%Y-%m-%d_%H:%M:%S'`: Time set." >> $LOG
        ### clean screen every hour as well
        $FBINK -f -c

        ### Disable WIFI
        #lipc-set-prop com.lab126.cmd wirelessEnable 0

        sleep 15 ## just in case RTC is drifting backwards...
    fi;

    #BAT=$(gasgauge-info -s | sed s/%//)
    BAT=$(cat cat /sys/devices/system/yoshi_battery/yoshi_battery0/battery_capacity)
    TIME=$(date '+%H:%M')
    DATE=$(date '+%A, %-d. %B %Y')

    ### Display time
    $FBINK -c -m -t \
        regular=/usr/java/lib/fonts/Caecilia_LT_65_Medium.ttf,size=150,top=10 "$TIME"

    $FBINK -m -t \
        regular=/usr/java/lib/fonts/Caecilia_LT_65_Medium.ttf,size=20,top=500,bottom=0,left=0,right=0\
        "$DATE"

    $FBINK -r -t \
        regular=/usr/java/lib/fonts/Caecilia_LT_65_Medium.ttf,size=10,top=0,bottom=0,left=900,right=0\
        "Bat: $BAT"

    # let the display update
    sleep 1

    ### Set Wakeuptimer
	#echo 0 > /sys/class/rtc/rtc1/wakealarm
	#echo ${WAKEUP_TIME} > /sys/class/rtc/rtc1/wakealarm
    NOW=$(date +%s)
    let WAKEUP_TIME="((($NOW + 59)/60)*60)" # Hack to get next minute
    let SLEEP_SECS=$WAKEUP_TIME-$NOW
    rtcwake -d /dev/rtc1 -m no -s $SLEEP_SECS
    echo "`date '+%Y-%m-%d_%H:%M:%S'`: Going to sleep for $SLEEP_SECS" >> $LOG
	### Go into Suspend to Memory (STR)
	echo "mem" > /sys/power/state
done

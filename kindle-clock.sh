#!/bin/sh

PWD=$(pwd)
FBINK="/mnt/us/extensions/MRInstaller/bin/K5/fbink"

wait_wlan() {
  return `lipc-get-prop com.lab126.wifid cmState | grep CONNECTED | wc -l`
}

# turn off 270 degree rotation of framebuffer device
echo 0 > /sys/devices/platform/mxc_epdc_fb/graphics/fb0/rotate

ntpdate -s us.pool.ntp.org

### Prepare Kindle, shutdown framework etc.
echo "------------------------------------------------------------------------"
echo "`date '+%Y-%m-%d_%H:%M:%S'`: Starting up, killing framework et. al."
### Maybe not a smart idea if script is started by KUAL
#/sbin/initctl stop framework

### Get rid of status bar
lipc-set-prop com.lab126.pillow disableEnablePillow disable

### Disable WAN interface (3G)
if [ -f /usr/sbin/wancontrol ] ; then
    lipc-set-prop com.lab126.wan stopWan 1
    wancontrol wanoff
fi




echo "`date '+%Y-%m-%d_%H:%M:%S'`: Entering main loop..."

while true; do

    echo "`date '+%Y-%m-%d_%H:%M:%S'`: Top of loop"
    ### Set lowest cpu clock
    echo powersave > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    ### Backlight off
    echo -n 0 > /sys/devices/system/fl_tps6116x/fl_tps6116x0/fl_intensity
	### Disable Screensaver
	lipc-set-prop com.lab126.powerd preventScreenSaver 1

    ### Set time every hour
    MINUTE=`date "+%M"`
    if [ "$MINUTE" = "00" ]; then
        ### Enable WIFI
    	lipc-set-prop com.lab126.cmd wirelessEnable 1
    	while wait_wlan; do
    	  sleep 1
    	done
    	echo `date '+%Y-%m-%d_%H:%M:%S'`: WIFI enabled!
        ntpdate -s us.pool.ntp.org
        sleep 15 ## just in case RTC is drifting backwards...
    fi;

    #BAT=$(gasgauge-info -s | sed s/%//)
    BAT=$(cat cat /sys/devices/system/yoshi_battery/yoshi_battery0/battery_capacity | sed s/%//)
	echo `date '+%Y-%m-%d_%H:%M:%S'`: battery level: $BAT
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
        "Bat: $BAT%"

    # let the display update
    sleep 1
    echo "`date '+%Y-%m-%d_%H:%M:%S'`: Display updated"


	### Disable WIFI
	#lipc-set-prop com.lab126.cmd wirelessEnable 0

    ### Set Wakeuptimer
	#echo 0 > /sys/class/rtc/rtc1/wakealarm
	#echo ${WAKEUP_TIME} > /sys/class/rtc/rtc1/wakealarm
    NOW=$(date +%s)
    let WAKEUP_TIME="((($NOW + 59)/60)*60)" # Hack to get next minute
    let SLEEP_SECS=$WAKEUP_TIME-$NOW
    echo `date '+%Y-%m-%d_%H:%M:%S'`: Wake-up time set for  `date -d @${WAKEUP_TIME}`
    echo `date '+%Y-%m-%d_%H:%M:%S'`: Sleeping for $SLEEP_SECS...
    rtcwake -d /dev/rtc1 -m no -s $SLEEP_SECS

	### Go into Suspend to Memory (STR)
	echo `date '+%Y-%m-%d_%H:%M:%S'`: Sleeping now...
	##echo "mem" > /sys/power/state
    exit
done

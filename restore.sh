#!/bin/sh

# turn on 270 degree rotation of framebuffer device
echo 3 > /sys/devices/platform/mxc_epdc_fb/graphics/fb0/rotate
#lipc-set-prop com.lab126.pillow disableEnablePillow enable
#killall -CONT cvm Xorg # resume framework
start framework

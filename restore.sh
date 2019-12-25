#!/bin/sh

# turn on 270 degree rotation of framebuffer device
echo 3 > /sys/devices/platform/mxc_epdc_fb/graphics/fb0/rotate
restart framework

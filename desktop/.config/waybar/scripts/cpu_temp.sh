#!/bin/bash
sensor=`find /sys/devices -name "name" | grep hwmon | while read f; do \grep -l k10temp $f; done | head -n1 | sed -e "s/name$//"`

mkdir -p ~/.local/devices
rm ~/.local/devices/cpu
ln -s $sensor ~/.local/devices/cpu

source @bashLib@
# the legacy script I used when the VGA cable
# still was attached to my old Linky switch
# to provide monitor for my laptop and the
# HDMI cable attached to provide monitor
# for work's laptop
#
# generated as follows: arandr to have
# a nice graphical view of monitors, also 
# there I applied changed config and
# when fitting saved to this exact shell
# script, the export arandr does, which is
# for testing on demand also but could be 
# called on certain system startup phases
# directly - I'll do slightly different.
#
# next is letting autorandr save that config
# to a profile just some name I gave it
# workstation as in `autorandr --save workstation`
# this profile now being loadable via
# `autorandr --load workstation` I saved the 
# exact same command to /etc/xprofile as in
# `autorandr --load workstation &`
# meaning on Archlinux it is loaded automatically
# with X window system.
#
# Saved another config with only laptop screen
# (when lid open) from arandr again
# loaded temporary in autorandr and saved
# to a profile named mobile that I load
# when laptop is off dock.
xrandr --output eDP-1 --mode 2880x1620_59.96 --pos 1920x0 --rotate normal --output VGA-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --off --output HDMI-2 --off

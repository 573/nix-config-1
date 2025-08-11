source @bashLib@
# the new script I use since HDMI cables
# are attached to my new KVM switch
# to provide one monitor via DVI shared by
# all laptops.
#
# generated as follows: arandr to have
# a nice graphical view of monitors, also 
# there I applied changed config and
# when fitting saved to this exact shell
# script - just in ~/.screenlayout/, 
# the export arandr does, which is
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
# TODO [when on NixOS] https://discourse.nixos.org/t/change-sddm-refresh-rate/68535/2
xrandr --output eDP-1 --off --output VGA-1 --off --output DP-1 --off --output HDMI-1 --off --output DP-2 --off --output HDMI-2 --off --output DP-2-1 --mode 1920x1080 --pos 0x0 --rotate normal --output DP-2-2 --off --output DP-2-3 --off

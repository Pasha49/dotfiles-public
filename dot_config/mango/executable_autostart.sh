#!/bin/bash

#set +e

uwsm finalize

gsettings set org.gnome.desktop.interface text-scaling-factor 1.25 &
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
systemctl --user start xdg-desktop-portal.service --now

uwsm app -t service -s background-graphical.slice -- noctalia
uwsm app -t service -s background-graphical.slice -- flameshot


#
#!/usr/bin/env bash

__SYSTEM=""
#FIXME: Auto detect DM?
__DM_TOOL="dm-tool lock"


function __auto_system () {
  if [[ -n $(which systemctl) ]]; then
    __SYSTEM="systemd"
  elif [[ -n $(which dbus-send) ]]; then
    __SYSTEM="dbus"
  elif [[ $(which loginctl) ]]; then
    __SYSTEM="loginctl"
  elif [[ -n $(which pm-suspend) ]]; then
    __SYSTEM="pm"
  else
    echo "UNSUPORTED SYSTEM!?"
    exit 1
  fi
}

function __suspend() {
  echo "$__SYSTME"
  if [[ $__SYSTEM == "systemd" ]]; then
    ${__DM_TOOL}
    systemctl suspend-then-hibernate
  elif [[ $__SYSTEM == "dbus" ]]; then
    ${__DM_TOOL}
    bus-send --system --print-reply\
    --dest=org.freedesktop.login1 /org/freedesktop/login
    "org.freedesktop.login1.Manager.Suspend"\
    boolean:true
  elif [[ $__SYSTEM == "loginctl" ]]; then
    ${__DM_TOOL}
    lloginctl suspend 
  elif [[ $__SYSTEM == "pm" ]]; then
    ${__DM_TOOL}
    pm_suspend
  else
    echo "UNSUPORTED SYSTEM!?"
    exit 1
  fi
}

function __parse_args() {
  # FIXME:
  echo "Argurment parsing is not implemented yet!"
}

function __main() {
  if [[ $# !=  0 ]]; then
    __parse_args $@
  else
    __auto_system $@
  fi
  
  __suspend $@

}

__main $@

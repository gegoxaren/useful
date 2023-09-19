#!/usr/bin/env bash
pkcon update --only-download &&\
  pkcon offline-trigger &&\
  systemctl reboot


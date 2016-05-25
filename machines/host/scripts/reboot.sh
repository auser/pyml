#!/usr/bin/env bash

# cuda needs reboot to configure properly
sudo reboot
sudo ifconfig eth0 down
sleep 60
sudo ifconfig eth0 up

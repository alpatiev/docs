#!/bin/bash

# Disable all updates in Debian/Ubuntu.
# TODO: check another services.

# 1. Disable unattended upgrades
sudo systemctl stop unattended-upgrades
sudo systemctl disable unattended-upgrades

# 2. Disable PackageKit
sudo systemctl stop packagekit
sudo systemctl disable packagekit

# 3. Disable Snapd
sudo systemctl stop snapd
sudo systemctl disable snapd

# 4. Disable apt-daily services
sudo systemctl stop apt-daily.timer
sudo systemctl stop apt-daily-upgrade.timer
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.timer

# 5. Purge DigitalOcean metrics agent
sudo apt-get purge do-agent

#!/bin/bash
source /etc/os-release

case ${ID} in
  rocky)
     sudo dnf install -q -y wget jq
  ;;
  ubuntu)
     # https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html
     export DEBIAN_FRONTEND=noninteractive
     sudo apt update
     sudo apt upgrade -y
     ###sudo reboot
#     sudo apt install -y ubuntu-desktop
#     sudo apt install -y jq wget
#     sudo apt install -y gdm3
#     sudo apt -y upgrade
#     sudo dpkg --configure -a
     ###sudo reboot
  ;;
  *)
    echo "No pre-requisites required"
  ;;
esac

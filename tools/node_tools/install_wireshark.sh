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
    
     sudo add-apt-repository -y ppa:wireshark-dev/stable
     sudo apt-get update
     echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
     sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark
     sudo usermod -aG wireshark $(whoami)
     ;;
  *)
    echo "No pre-requisites required"
    ;;
esac

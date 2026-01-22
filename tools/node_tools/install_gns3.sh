#!/bin/bash
source /etc/os-release

case ${ID} in
  rocky)
     sudo dnf install -q -y wget jq
     ;;
  ubuntu)
     # https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html
     #export DEBIAN_FRONTEND=noninteractive
     #sudo apt update
     
     #sudo add-apt-repository -y ppa:gns3/ppa
     #sudo apt-get update
     #echo "gns3-gui gns3-gui/install-setuid boolean true" | sudo debconf-set-selections
     #echo "gns3-server gns3-server/install-setuid boolean true" | sudo debconf-set-selections
     #sudo DEBIAN_FRONTEND=noninteractive apt install -y unattended-upgrades gns3-gui gns3-server

     # IOU support
     #sudo dpkg --add-architecture i386
     #sudo apt update
     #sudo apt install -y gns3-iou


     #
     # Wireshark - Install
     #

     sudo add-apt-repository -y ppa:wireshark-dev/stable
     sudo apt-get -y update
     echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
     sudo DEBIAN_FRONTEND=noninteractive apt-get -y install wireshark
     sudo usermod -aG wireshark $(whoami)

     #
     # Docker - Install
     #

     # To install Docker CE (Xenial_and_newer)
     sudo apt remove docker docker-engine docker.io
     sudo snap remove docker

     sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

     sudo add-apt-repository -y \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable"

     sudo apt update -y
     sudo apt install -y docker-ce

     sudo usermod -aG docker $(whoami)


     #
     # GNS3 - Install
     #

     sudo add-apt-repository -y ppa:gns3/ppa
     sudo apt-get update -y
     echo "gns3-gui gns3-gui/install-setuid boolean true" | sudo debconf-set-selections
     echo "gns3-server gns3-server/install-setuid boolean true" | sudo debconf-set-selections
     sudo DEBIAN_FRONTEND=noninteractive apt install -y unattended-upgrades gns3-gui gns3-server

     # IOU support
     sudo dpkg --add-architecture i386
     sudo apt update -y
     sudo apt install -y gns3-iou


     # Finally, add your user to the following groups:
     # ubridge libvirt kvm wireshark docker

     sudo usermod -aG ubridge,libvirt,kvm,wireshark,docker $(whoami)


     # Update the package index:
     sudo apt-get -y update
     # Install dynamips deb package:
     sudo apt-get -y install dynamips

     sudo apt -y install xterm

     ;;
     
  *)
     echo "No pre-requisites required"
     ;;
esac

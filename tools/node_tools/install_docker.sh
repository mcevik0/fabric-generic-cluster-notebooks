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

     # To install Docker CE (Xenial_and_newer)
     sudo apt remove docker docker-engine docker.io
     sudo snap remove docker

     sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
     curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

     sudo add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) stable"

     sudo apt update
     sudo apt install -y docker-ce

     sudo usermod -aG docker $(whoami)  
     ;;
  *)
     echo "No pre-requisites required"
     ;;
esac

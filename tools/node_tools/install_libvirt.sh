#!/bin/bash
source /etc/os-release


enable_x11_forwarding_debian (){
     sudo sed -i '/#X11Forwarding/s/^#//g' /etc/ssh/sshd_config
     sudo systemctl restart ssh
     sudo apt-get update && sudo apt-get -y install x11-apps
     sudo apt-get -y install xauth
     # ---
     # To open virt-manager from the user "debian" and be able to connect to the privileged QEMU session
     # ---
     USER_TO_ALLOW=$1
     sudo usermod --append --groups libvirt ${USER_TO_ALLOW}
     sudo systemctl restart libvirtd

}

enable_x11_forwarding_rocky (){
    sudo dnf install -y xorg-x11-xauth xorg-x11-fonts-\* xorg-x11-utils dbus-x11
    sudo sed -i '/#X11Forwarding/s/^#//g' /etc/ssh/sshd_config
    sudo systemctl restart sshd.service

    init 5

    # ---
    # To open virt-manager from the user rocky and be able to connect to the privileged QEMU session
    # ---
    USER_TO_ALLOW=$1
    sudo usermod --append --groups libvirt ${USER_TO_ALLOW}
    sudo systemctl restart libvirtd
}

libvirt_activate_nat (){
     sudo virsh net-list --all
     sudo virsh net-autostart default
     sudo virsh net-start default
     sudo virsh net-list --all
}


case ${ID} in

  rocky)
     SERVICE_USER="rocky"

     # ---
     # 1. Install Libvirtd
     # ---

     sudo dnf install -q -y wget jq
     sudo dnf install -y epel-release
     sudo dnf install qemu-kvm virt-manager libvirt virt-install virt-viewer virt-top bridge-utils  bridge-utils virt-top libguestfs-tools -y
     sudo systemctl start libvirtd
     sudo systemctl enable --now libvirtd
     sudo systemctl status libvirtd
     
     # ---
     # 2. Enable X11 Forwarding
     # ---
     
     enable_x11_forwarding_rocky ${SERVICE_USER}
     
     # To launch virt-manager 
     # Log out and log in with the $USER_TO_ALLOW, then execute
     #virt-manager


     # ---
     # 3. Activate NAT network (default)
     # ---
     
     libvirt_activate_nat
     
     ;;
     
  debian)
     SERVICE_USER="debian"

     # ---
     # 1. Install Libvirtd
     # ---
     sudo sed -i -r "/127.0.0.1/ s/$/ `hostname`/" /etc/hosts
     sudo apt -y update
     sudo apt -y install qemu-kvm libvirt-daemon libvirt-clients bridge-utils virtinst libvirt-daemon-system qemu-system-common
     sudo modprobe vhost_net
     lsmod | grep vhost
     echo vhost_net | sudo tee -a /etc/modules 
     sudo apt -y install vim libguestfs-tools libosinfo-bin  qemu-system virt-manager


     # ---
     # 2. Enable X11 Forwarding
     # ---
    
     enable_x11_forwarding_debian ${SERVICE_USER}
     
     # To launch virt-manager 
     # Log out and log in with the $USER_TO_ALLOW, then execute
     #virt-manager


     # ---
     # 3. Activate NAT network (default)
     # ---
     
     libvirt_activate_nat
     
     ;;

  *)
     echo "No pre-requisites required"
     ;;
esac


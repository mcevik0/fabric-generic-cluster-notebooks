#!/bin/bash
source /etc/os-release


download_images (){
     wget -q https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso
     wget -q https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9-latest-x86_64-minimal.iso
     wget -q https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2


     ln -s ubuntu-22.04.5-live-server-amd64.iso ubuntu-22.iso
     ln -s Rocky-9-latest-x86_64-minimal.iso rocky-9.iso 
     ln -s Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 rocky-9.qcow
     
     sudo cp Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 /var/lib/libvirt/images/rocky-9.qcow2
}


create_ssh_key (){
     USERNAME=$1
     HOSTNAME=$(hostname)
     ssh-keygen -C "${USERNAME}@${HOSTNAME}" -t ed25519 -b 2048 -f ~/.ssh/id_ed25519 -q -N ""

}


create_user_data (){
     USER_DATA=$1
     USERNAME=$2
     
     cat << EOF > ${USER_DATA}
#cloud-config

groups:
  - docker

users:
  - name: clouduser
    gecos: Cloud User
    primary_group: clouduser
    groups: docker
    home: /home/clouduser
    shell: /bin/bash
    lock_passwd: true
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - $(cat ~/.ssh/id_ed25519.pub)
package_upgrade: true
EOF
     chown ${USERNAME}:${USERNAME} ${USER_DATA}   

}

create_vm (){
     USER_DATA=$1
     sudo virt-install \
          --name rockyvm \
          --memory 2048 \
          --vcpus 2 \
          --os-variant rocky9 \
          --network network=default,model=virtio \
          --graphics vnc  \
          --disk /var/lib/libvirt/images/rocky-9.qcow2 \
          --cloud-init user-data="${USER_DATA}"
}


case ${ID} in
  rocky)
  
     SERVICE_USER="rocky"
     USER_DATA_FILE="user-data.yml"

     sudo dnf install -q -y wget jq
     
     # ---
     # 4. Download Images
     # ---
     download_images

     # ---
     # 5. Create SSH key and user-data.yml
     # ---
     create_ssh_key ${SERVICE_USER}


     # Create user-data.yml file
     create_user_data ${USER_DATA_FILE} `whoami`


     # ---
     # 6. Create VM
     # ---
     USER_DATA="/home/rocky/user-data.yml"
     create_vm ${USER_DATA}

     ;;
     
  debian)
     SERVICE_USER="debian"
     USER_DATA_FILE="user-data.yml"

     # ---
     # 4. Download Images
     # ---
     download_images

     
     # ---
     # 5. Create SSH key and user-data.yml
     # ---
     create_ssh_key ${SERVICE_USER}


     # Create user-data.yml file
     create_user_data ${USER_DATA_FILE} `whoami`


     # ---
     # 6. Create VM
     # ---
     USER_DATA="/home/debian/user-data.yml"
     create_vm ${USER_DATA}

     ;;
     
  *)
    echo "No pre-requisites required"
    ;;
esac


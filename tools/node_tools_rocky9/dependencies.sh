#!/bin/bash

image=$1

architecture='x86_64'

if [[ $image == "default_ubuntu_20" || $image == "default_ubuntu_22" || $image == "docker_ubuntu_20" || $image == "docker_ubuntu_22" ]]; then
    distro=$(. /etc/os-release; echo ${ID}${VERSION_ID//./})

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y pciutils && lspci | grep -E 'NVIDIA|3D controller'
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q install -y linux-headers-$(uname -r) gcc

    wget https://developer.download.nvidia.com/compute/cuda/repos/$distro/$architecture/cuda-keyring_1.1-1_all.deb
    sudo DEBIAN_FRONTEND=noninteractive dpkg -i cuda-keyring_1.1-1_all.deb
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q update
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q install -y cuda

    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
        && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
        && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo DEBIAN_FRONTEND=noninteractive apt-get -q update
    sudo DEBIAN_FRONTEND=noninteractive apt install -q -y nvidia-container-toolkit
    sudo systemctl restart docker

elif [[ $image == "default_rocky_8" || $image == "default_rocky_9" || $image == "docker_rocky_8" || $image == "docker_rocky_9" ]]; then
    distro='rhel9'

    sudo dnf install -y pciutils && lspci | grep -E 'NVIDIA|3D controller'

    # Step 1: Enable CRB repo (required for some build dependencies)
    sudo dnf config-manager --set-enabled crb

    # Step 2: Add CUDA repo
    sudo dnf config-manager --add-repo \
        https://developer.download.nvidia.com/compute/cuda/repos/${distro}/${architecture}/cuda-${distro}.repo

    # Step 3: Install CUDA toolkit
    sudo dnf -q -y install cuda-toolkit

    # Step 4: Install EPEL (provides dkms >= 3.1.8, required by nvidia-gds)
    sudo dnf -q -y install epel-release

    # Step 5: Install nvidia-gds (pulls in drivers, open kernel module, dkms, etc.)
    sudo dnf -q -y install nvidia-gds

    # Step 6: Install NVIDIA container toolkit
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo \
        | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
    sudo dnf install -y nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker

else
    echo "Invalid or unsupported image type: $image"
    exit 1
fi

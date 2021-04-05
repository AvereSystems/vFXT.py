#!/bin/bash

set -ex

cd /usr/local/bin

grep "centos:8" /etc/os-release && centOS8=true || centOS8=false
if $centOS8; then
    dnf -y install nfs-utils
else # centOS7
    yum -y install nfs-utils
fi

lshw -class "display" | grep "NVIDIA" && gpuNVIDIA=true || gpuNVIDIA=false
if $gpuNVIDIA; then
    if $centOS8; then
        dnf -y install gcc
        dnf -y install make
        dnf -y install "kernel-devel-uname-r == $(uname -r)"
        dnf -y install epel-release
        dnf -y install dkms
    else # centOS7
        yum -y install gcc
        yum -y install "kernel-devel-uname-r == $(uname -r)"
    fi
    fileName="NVIDIA-Linux-x86_64-460.32.03-grid-azure.run"
    containerUrl="https://bit1.blob.core.windows.net/bin/Graphics/Linux"
    curl -L -o $fileName $containerUrl/$fileName
    chmod +x $fileName
    ./$fileName -s
fi

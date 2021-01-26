#!/bin/bash

set -ex

grep 'centos:7' /etc/os-release && centOS7=true || centOS7=false

if $centOS7; then
    yum -y install nfs-utils
    yum -y install epel-release
    yum -y install jq
    yum -y install java-11-openjdk
    yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    yum -y install postgresql12
else # CentOS8
    dnf -y install nfs-utils
    dnf -y install jq
    dnf -y install java-11-openjdk
    dnf -y module disable postgresql
    dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
    dnf -y install postgresql12
fi

cd /usr/local/bin

downloadUrl='https://usawest.blob.core.windows.net/bin/OpenCue/v0.4.95'

fileName='opencue-bot-schema.sql'
curl -L -o $fileName $downloadUrl/$fileName

fileName='opencue-bot-data.sql'
curl -L -o $fileName $downloadUrl/$fileName

fileName='opencue-bot.jar'
curl -L -o $fileName $downloadUrl/$fileName

fileName='opencue-bot.service'
curl -L -o $fileName $downloadUrl/$fileName
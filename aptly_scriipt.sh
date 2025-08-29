#!/usr/bin/env bash

##List of Distros
distros=("debian" "trixie")
packages=("main" "contrib" "non-free" "non-free-firmware" "backport")
# loop through distros
for distro in "${distros[@]}"; do 
    for package in "${packages[@]}"; do
        echo "$distro and $package"
    done
done
#!/usr/bin/env bash

set -e
##List of Distros
distros=("bookworm")
#distros=("debian" "trixie")
#packages=("main" "contrib" "non-free" "non-free-firmware" "backport")
# loop through distros and create mirrors
for distro in "${distros[@]}"; do 
    #for package in "${packages[@]}"; do
        #echo "$distro and $package"
        echo "aptly mirror -architectures="amd64" create debian-$distro-main http://deb.debian.org/debian/ $distro main"
        echo "aptly mirror -architectures="amd64" create debian-$distro-non-free http://deb.debian.org/debian/ $distro non-free"
        echo "aptly mirror -architectures="amd64" create debian-$distro-non-free-firmware http://deb.debian.org/debian/ $distro non-free-firmware"
        echo "aptly mirror -architectures="amd64" create debian-$distro-contrib http://deb.debian.org/debian/ $distro contrib"
        echo "aptly mirror -architectures="amd64" create debian-$distro-backports http://deb.debian.org/debian/ $distro-backports main"
    #done
#done

#update mirrors
        echo "-------------------------------------------------------->"
        echo "Now the distros are gonna be updated"
        echo "aptly mirror list -raw | xargs -n 1 aptly mirror update"

#Create snapshot 
        echo "aptly snapshot create debian-$distro-main-$(date +%Y%m%d) from mirror debian-$distro-main"
        echo "aptly snapshot create debian-$distro-non-free-$(date +%Y%m%d) from mirror debian-$distro-non-free"
        echo "aptly snapshot create debian-$distro-non-free-firmware-$(date +%Y%m%d) from mirror debian-$distro-non-free-firmware"
        echo "aptly snapshot create debian-$distro-contrib-$(date +%Y%m%d) from mirror debian-$distro-contrib"

        echo "aptly publish snapshot -distribution=bookworm -component=main,non-free,non-free-firmware,contrib -architectures=amd64 debian-bookworm-main-$(date +%Y%m%d) debian-bookworm-non-free-$(date +%Y%m%d)  debian-bookworm-non-free-firmware-$(date +%Y%m%d) debian-bookworm-contrib-$(date +%Y%m%d)"
done
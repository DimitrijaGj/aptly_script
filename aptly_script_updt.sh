#!/usr/bin/env bash

set -e
##List of Distros
# Crette check for mirrors
if aptly mirror list -raw | grep -q "debian-bookworm"; then
    echo "Debian bookworm mirrors already exist, skipping creation phase..."
    CREATE_MIRRORS=false
else
    echo "No mirrors found, will create them..."
    CREATE_MIRRORS=true
fi
distros=("bookworm")
#distros=("debian" "trixie")
#packages=("main" "contrib" "non-free" "non-free-firmware" "backport")
#versions
# loop through distros and create mirrors

for distro in "${distros[@]}"; do
    #for package in "${packages[@]}"; do
        #echo "$distro and $package"

 # Create mirrors
        if [ "$CREATE_MIRRORS" = true ]; then
        echo "Creating mirrors for $distro..."
        aptly mirror -architectures="amd64" create debian-$distro-main http://deb.debian.org/debian/ $distro main
        aptly mirror -architectures="amd64" create debian-$distro-non-free http://deb.debian.org/debian/ $distro non-free
        aptly mirror -architectures="amd64" create debian-$distro-non-free-firmware http://deb.debian.org/debian/ $distro non-free-firmware
        aptly mirror -architectures="amd64" create debian-$distro-contrib http://deb.debian.org/debian/ $distro contrib
        aptly mirror -architectures="amd64" create debian-$distro-backports http://deb.debian.org/debian/ $distro-backports main
    #done
#done
        fi
# Update mirrors
    aptly mirror list -raw | xargs -n 1 aptly mirror update

# Create snapshot

    aptly snapshot create debian-$distro-main-$(date +%Y%m%d) from mirror debian-$distro-main
    aptly snapshot create debian-$distro-non-free-$(date +%Y%m%d) from mirror debian-$distro-non-free
    aptly snapshot create debian-$distro-non-free-firmware-$(date +%Y%m%d) from mirror debian-$distro-non-free-firmware
    aptly snapshot create debian-$distro-contrib-$(date +%Y%m%d) from mirror debian-$distro-contrib
# Publish the snapshots
     if [ "$CREATE_MIRRORS" = true ]; then
    aptly publish snapshot -distribution=bookworm -component=main,non-free,non-free-firmware,contrib -architectures=amd64 debian-bookworm-main-$(date +%Y%m%d) debian-bookworm-non-free-$(date +%Y%m%d)  debian-bookworm-non-free-firmware-$(date +%Y%m%d) debian-bookworm-contrib-$(date +%Y%m%d)
     fi
# switch to newer snapshot
    aptly publish switch -component=main,non-free,non-free-firmware,contrib bookworm debian-bookworm-main-$(date +%Y%m%d) debian-bookworm-non-free-$(date +%Y%m%d) debian-bookworm-non-free-firmware-$(date +%Y%m%d) debian-bookworm-contrib-$(date +%Y%m%d)


# Clean up old snapshots (keeping latest 2)
    aptly snapshot list -raw | grep debian-$distro | sort | head -n -3 | xargs -r -n1 sudo aptly snapshot drop
    aptly db cleanup

done

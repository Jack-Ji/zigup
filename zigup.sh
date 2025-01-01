#!/bin/bash

if [ $# -eq 0 ] && [ -e .zigversion ]; then
    version=`cat .zigversion`
elif [ $# -ne 1 ]; then
    echo "usage: zigup.sh master|0.13.0|0.13.0-dev.351+64ef45eb0"
    exit -1
else
    version=$1
fi

set -e

if echo $version | grep -q dev; then
    pkg=zig-linux-x86_64-$version.tar.xz
    url=https://ziglang.org/builds/$pkg
else
    url=`curl -s https://ziglang.org/download/index.json | jq --arg V $version '.[$V]."x86_64-linux".tarball' | sed 's/"//g'`
    pkg=`echo $url | awk -F / '{print $NF}'`
fi

target_ver=${pkg%.tar.xz}
current_ver=`file /usr/local/bin/zig | awk -F / '{print $(NF-1)}'`
if [ "$current_ver" = "$target_ver" ]; then
    echo "No need to do anything, you are good to go."
    exit 0
fi

if [ ! -e ~/.zigup/ ]; then
    mkdir -p ~/.zigup
fi

if [ ! -e ~/.zigup/$pkg ]; then
    wget -c $url && mv $pkg ~/.zigup/
fi
tar -xJvf ~/.zigup/$pkg -C ~/.zigup

echo "You might need to input sudo password..."
sudo ln -sf ~/.zigup/$target_ver/zig /usr/local/bin

echo "$(zig version) is ready for you now!"

#!/bin/bash

set -e

if [ $# -ne 1 ]; then
    echo "usage: zigup.sh master|0.13.0|0.13.0-dev.351+64ef45eb0"
    exit -1
fi

case $1 in
    master)
        pkg=`curl -s https://ziglang.org/download/index.json | jq '.master."x86_64-linux".tarball' | sed 's/"//g' | awk -F / '{print $NF}'`
        ;;

    *)
        pkg="zig-linux-x86_64-$1.tar.xz"
        ;;
esac

curver=`file /usr/local/bin/zig | awk -F / '{print $(NF-1)}'`
if [ $curver = ${pkg%.tar.xz} ]; then
    echo "No need to do anything, you are good to go."
    exit 0
fi

if [ ! -e ~/.zigup/ ]; then
    mkdir -p ~/.zigup
fi

url="https://ziglang.org/builds/$pkg"
if [ ! -e ~/.zigup/$pkg ]; then
    if [ $1 = master ]; then
        ver=${pkg%.tar.xz}
        rm -rf ~/.zigup/${ver%dev*}*
    fi
    wget -c $url && mv $pkg ~/.zigup/
    tar -xJvf ~/.zigup/$pkg -C ~/.zigup
fi

echo "You might need to input sudo password..."
sudo ln -sf ~/.zigup/${pkg%.tar.xz}/zig /usr/local/bin

echo "$(zig version) is ready for you now!"

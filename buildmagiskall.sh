#!/bin/bash

SRC_ROOT=$(dirname $(readlink -f $0))

if [ -d "$SRC_ROOT/libsodium" ]; then
    cd $SRC_ROOT/libsodium
    git pull
else
    git clone https://github.com/jedisct1/libsodium.git
fi

if [ -d "$SRC_ROOT/dnscrypt-proxy" ]; then
    cd $SRC_ROOT/dnscrypt-proxy
    git pull
else
    git clone https://github.com/jedisct1/dnscrypt-proxy.git
fi

if [ -d "$SRC_ROOT/dnscrypt-magisk" ]; then
    cd $SRC_ROOT/dnscrypt-magisk
    git pull
else
    git clone https://github.com/barrybingo/dnscrypt-magisk.git
fi


cd $SRC_ROOT/libsodium

./autogen.sh
./configure 

./dist-build/android-arm.sh 
./dist-build/android-armv8-a.sh
./dist-build/android-x86.sh 

#folder is being named westmere for the x86-64 architecture
if [ ! -e libsodium-android-x86-64 ]; then
    ln -sn libsodium-android-westmere libsodium-android-x86-64
fi

rm -rf /tmp/libsodium-android-*
cp -a libsodium-android-* /tmp

cd $SRC_ROOT/dnscrypt-proxy

./autogen.sh

./dist-build/android-arm.sh 
./dist-build/android-armv8-a.sh
./dist-build/android-x86.sh 

cd $SRC_ROOT 

rm -rf $SRC_ROOT/dnscrypt-magisk/system
mkdir -p $SRC_ROOT/dnscrypt-magisk/system/etc
cp -a dnscrypt-proxy/dnscrypt-proxy-android-i686/system/etc/dnscrypt-proxy    $SRC_ROOT/dnscrypt-magisk/system/etc

mkdir -p $SRC_ROOT/dnscrypt-magisk/system/xbin
cp dnscrypt $SRC_ROOT/dnscrypt-magisk/system/xbin


rm -rf $SRC_ROOT/dnscrypt-magisk/arm/
mkdir -p $SRC_ROOT/dnscrypt-magisk/arm/system

rm -rf $SRC_ROOT/dnscrypt-magisk/arm64
mkdir -p $SRC_ROOT/dnscrypt-magisk/arm64/system

rm -rf $SRC_ROOT/dnscrypt-magisk/x86
mkdir -p $SRC_ROOT/dnscrypt-magisk/x86/system


cp -a dnscrypt-proxy/dnscrypt-proxy-android-armv6/system/lib   $SRC_ROOT/dnscrypt-magisk/arm//system/lib
cp -a dnscrypt-proxy/dnscrypt-proxy-android-armv8-a/system/lib $SRC_ROOT/dnscrypt-magisk/arm64/system/lib64
cp -a dnscrypt-proxy/dnscrypt-proxy-android-i686/system/lib    $SRC_ROOT/dnscrypt-magisk/x86/system/lib

cp -a dnscrypt-proxy/dnscrypt-proxy-android-armv6/system/xbin   $SRC_ROOT/dnscrypt-magisk/arm/system
cp -a dnscrypt-proxy/dnscrypt-proxy-android-armv8-a/system/xbin $SRC_ROOT/dnscrypt-magisk/arm64/system
cp -a dnscrypt-proxy/dnscrypt-proxy-android-i686/system/xbin    $SRC_ROOT/dnscrypt-magisk/x86/system

rm $SRC_ROOT/dnscrypt-magisk/arm/system/xbin/dnscrypt
rm $SRC_ROOT/dnscrypt-magisk/arm64/system/xbin/dnscrypt
rm $SRC_ROOT/dnscrypt-magisk/x86/system/xbin/dnscrypt

rm $SRC_ROOT/dnscrypt-magisk.zip
(cd $SRC_ROOT/dnscrypt-magisk;  7z a -tzip -mx=9 -r $SRC_ROOT/dnscrypt-magisk.zip * )


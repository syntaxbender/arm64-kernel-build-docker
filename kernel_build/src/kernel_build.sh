#!/bin/bash
DEBIAN_FRONTEND="noninteractive"
KERNEL_BRANCH=rpi-6.6.y
KERNEL_GIT=https://github.com/raspberrypi/linux.git
HELPER_GIT=https://github.com/syntaxbender/pi-ci.git

BASE_DIR=/rasp

BUILD_DIR=$BASE_DIR/build
KERNEL_DIR=$BASE_DIR/linux
HELPER_REPO_DIR=$BASE_DIR/pi-ci
CUSTOM_CONFIG_FILE=$HELPER_REPO_DIR/src/conf/custom.conf

ARCH=arm64
CROSS_COMPILE=aarch64-linux-gnu-

IMAGE_FILE_NAME=distro.qcow2
KERNEL_FILE_NAME=kernel.img

mkdir -p $BUILD_DIR \
 && echo "1- Directories created";

git clone --single-branch --branch $KERNEL_BRANCH $KERNEL_GIT $KERNEL_DIR \
 && git clone $HELPER_GIT $HELPER_REPO_DIR \
 && echo "2- Git repositories cloned"

cp $CUSTOM_CONFIG_FILE $KERNEL_DIR/kernel/configs/custom.config \
 && echo "3- Custom kernel config copied"

cd $KERNEL_DIR

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -C $KERNEL_DIR defconfig kvm_guest.config custom.config \
 && make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -C $KERNEL_DIR -j$(nproc) Image \
 && echo "4- Kernel built success"

mv $KERNEL_DIR/arch/arm64/boot/Image $BUILD_DIR/kernel.img \
 && cp $BUILD_DIR/kernel.img /out \
 && echo "5- Copied built kernel to out"
#!/bin/bash

# Distro source
DEBIAN_FRONTEND="noninteractive"
DISTRO_LINK=https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz
DISTROXZ_FILE=2024-07-04-raspios-bookworm-arm64-lite.img.xz
DISTRO_FILE=2024-07-04-raspios-bookworm-arm64-lite.img

HELPER_GIT=https://github.com/syntaxbender/pi-ci.git

BASE_DIR=/rasp

BUILD_DIR=$BASE_DIR/build
IMAGE_DIR=$BASE_DIR/image
HELPER_REPO_DIR=$BASE_DIR/pi-ci

MOUNT_ROOT_DIR=/mnt/root
MOUNT_BOOT_DIR=/mnt/boot

USER_PASSWORD=raspberry

mkdir -p $IMAGE_DIR \
 && mkdir -p $BUILD_DIR \
 && mkdir $MOUNT_BOOT_DIR $MOUNT_ROOT_DIR \
 && echo "1- Created mount & required dirs"

git clone $HELPER_GIT $HELPER_REPO_DIR \
 && echo "2- Git repositories cloned"

wget -nv -O $IMAGE_DIR/$DISTROXZ_FILE $DISTRO_LINK \
 && unxz $IMAGE_DIR/$DISTROXZ_FILE \
 && echo "3- Download distro & extract"

# qemu-img resize $IMAGE_DIR/$DISTRO_FILE 8G

# modprobe loop 
# mkdir -p $MOUNT_BOOT_DIR
# mkdir -p $MOUNT_ROOT_DIR

# RPI_LOOP_DEV=$(losetup -f --show $IMAGE_DIR/$DISTRO_FILE)

# parted $RPI_LOOP_DEV resizepart 2 100%
# resize2fs "${RPI_LOOP_DEV}p2"

# mount "${RPI_LOOP_DEV}p1" $MOUNT_BOOT_DIR
# mount "${RPI_LOOP_DEV}p2" $MOUNT_ROOT_DIR

guestfish add $IMAGE_DIR/$DISTRO_FILE : run : mount /dev/sda1 / : copy-out / $MOUNT_BOOT_DIR : umount / : mount /dev/sda2 / : copy-out / $MOUNT_ROOT_DIR \
 && echo "4- Copied partition files to mount directories"

cp $HELPER_REPO_DIR/src/conf/fstab $MOUNT_ROOT_DIR/etc/ \
 && cp $HELPER_REPO_DIR/src/conf/99-qemu.rules $MOUNT_ROOT_DIR/etc/udev/rules.d/ \
 && cp $HELPER_REPO_DIR/src/conf/cmdline.txt $MOUNT_BOOT_DIR/ \
 && echo "5- Copied config files to mount directories"

SHADOW_SHA512=$(openssl passwd -6 $USER_PASSWORD) \
 && touch $MOUNT_BOOT_DIR/ssh \
 && echo "pi:$SHADOW_SHA512" > $MOUNT_BOOT_DIR/userconf \
 && echo "6- Created pi user & ssh enabled"

guestfish -N $BUILD_DIR/distro.img=bootroot:vfat:ext4:4G : quit > /dev/null 2>&1
guestfish add $BUILD_DIR/distro.img : run : mount /dev/sda1 / : glob copy-in $MOUNT_BOOT_DIR/* / : umount / : mount /dev/sda2 / : glob copy-in $MOUNT_ROOT_DIR/* / \
 && sfdisk --part-type $BUILD_DIR/distro.img 1 c \
 && echo "7- Created new image file"

# umount $MOUNT_BOOT_DIR
# umount $MOUNT_ROOT_DIR
# losetup -d $RPI_LOOP_DEV

qemu-img convert -f raw -O qcow2 $BUILD_DIR/distro.img $BUILD_DIR/distro.qcow2 \
 && echo "8- Converted image file to qemu virtual disk file"

cp $BUILD_DIR/distro.qcow2 /out \
 && echo "9- Copied built image to out"

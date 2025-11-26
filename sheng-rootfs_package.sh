#!/bin/sh

find $1/.. -name 'rootfs.7z' -exec mv "{}" $1/  \;

7z x rootfs.7z

mkdir rootdir
mount -o loop rootfs.img rootdir

mkdir -p rootdir/data/local/tmp
mount --bind /dev rootdir/dev
mount --bind /dev/pts rootdir/dev/pts
mount --bind /proc rootdir/proc
mount -t tmpfs tmpfs rootdir/data/local/tmp
mount --bind /sys rootdir/sys

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\$PATH
export DEBIAN_FRONTEND=noninteractive

find $1/.. -name 'alsa-xiaomi-sheng.deb' -exec cp "{}" $1/rootdir/  \;
find $1/.. -name 'firmware-xiaomi-sheng.deb' -exec cp "{}" $1/rootdir/  \;
find $1/.. -name 'device-xiaomi-sheng.deb' -exec cp "{}" $1/rootdir/  \;
find $1/.. -name 'linux-xiaomi-sheng.deb' -exec cp "{}" $1/rootdir/ \;
chroot rootdir sudo apt update
chroot rootdir sudo apt install -y language-pack-zh-hans language-pack-zh-hant
chroot rootdir sudo locale-gen zh_CN.UTF-8 zh_TW.UTF-8
chroot rootdir echo 'LANG="zh_CN.UTF-8"' | sudo tee /etc/default/locale
chroot rootdir echo 'LANGUAGE="zh_CN:zh"' | sudo tee -a /etc/default/locale
chroot rootdir apt update
chroot rootdir apt upgrade -y
chroot rootdir apt install -y python3-defer
sudo timedatectl set-timezone Asia/Shanghai
chroot rootdir dpkg -i alsa-xiaomi-sheng.deb
chroot rootdir dpkg -i firmware-xiaomi-sheng.deb
chroot rootdir dpkg -i device-xiaomi-sheng.deb
chroot rootdir dpkg -i linux-xiaomi-sheng.deb
rm -rf $1/rootdir/*.deb

# Tambah user
chroot rootdir useradd -m -s /bin/bash admin
chroot rootdir useradd -m -s /bin/bash root

# Set password
chroot rootdir /bin/bash -c "echo 'admin:admin' | chpasswd"
chroot rootdir /bin/bash -c "echo 'root:admin' | chpasswd"

# Tambah ke grup sudo
chroot rootdir usermod -aG sudo admin


umount rootdir/sys
umount rootdir/proc
umount rootdir/dev/pts
umount rootdir/data/local/tmp
umount rootdir/dev
umount rootdir

rm -d rootdir

7z a rootfs.7z rootfs.img

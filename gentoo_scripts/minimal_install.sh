#!/bin/bash

ifconfig -a | less
echo "Which network interface will you be using?: "
read nif

net-setup $nif

parted -a optimal --script /dev/sda \
       mklabel gpt \
       unit mib \
       mkpart primary 1 3 \
       name 1 grub \
       set 1 bios_grub on \
       mkpart primary 3 131 \
       name 2 boot \
       mkpart primary 131 -1 \
       name 3 rootfs

mkfs.ext2 /dev/sda2
mkfs.ext4 /dev/sda3

mount /dev/sda3 /mnt/gentoo

dd if=/dev/zero of=/mnt/gentoo/swapfile bs=1Mib count=2048
chmod 600 /mnt/gentoo/swapfile
mkswap /mnt/gentoo/swapfile
swapon /mnt/gentoo/swapfile

ntpd -q -g

cd /mnt/gentoo

wget -r -l1 --no-parent -A "stage3-amd64-*.tar.xz" https://distfiles.gentoo.org/releases/amd64/autobuilds/

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

echo "COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}" 
MAKEOPTS="-j4" 
VIDEO_CARDS="intel nvidia"" > /mnt/gentoo/etc/portage/make.conf

mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf

mkdir --parents /mnt/gentoo/etc/portage/repos.conf

cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"

mkdir /boot
mount /dev/sda2 /boot

emerge-webrsync
emerge --sync

eselect profile list | less

echo "Which profile do you want?: "
read prof

eselect profile set $prof

emerge -vuDN @world

echo "America/Chicago" > /etc/timezone

emerge --config sys-libs/timezone-data

echo "LANG="en_US.UTF-8"
LC_COLLATE="C"" > /etc/env.d/02locale

env-update && source /etc/profile && export PS1="(chroot) $PS1"

emerge -v sys-kernel/gentoo-sources

emerge -v sys-kernel/genkernel

echo "/dev/sda2	/boot	ext2	defaults,noatime	0 2" > /etc/fstab

genkernel all

emerge -v sys-kernel/linux-firmware

echo "/dev/sda3   /            ext4    noatime              0 1" >> /etc/fstab

echo "hostname="void"" > /etc/conf.d/hostname

cd /etc/init.d 
ln -s net.lo net.$nif
rc-update add net.nif default

echo "Set the root password\n"
passwd

emerge -v app-admin/sysklogd
rc-update add sysklogd default

emerge -v sys-fs/e2fsprogs
emerge -v sys-fs/dosfstools

emerge -v net-misc/dhcpcd
emerge -v net-wireless/iw net-wireless/wpa_supplicant

emerge -v --verbose sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot

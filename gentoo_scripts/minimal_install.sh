#!/bin/sh

parted --script -a optimal -- /dev/sda \
       mklabel gpt \
       unit mib \
       mkpart primary 1 100 \
       name 1 efi \
       set 1 bios_grub on \
       set 1 boot on \
       mkpart primary 100 -1 \
       name 2 rootfs

mkfs.fat -F 32 -n efi-boot /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt/gentoo

dd if=/dev/zero of=/mnt/gentoo/swapfile bs=1MB count=2048
chmod 600 /mnt/gentoo/swapfile
mkswap /mnt/gentoo/swapfile
swapon /mnt/gentoo/swapfile

ntpd -q -g

cd /mnt/gentoo

links https://gentoo.org/downloads/

tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

echo 'COMMON_FLAGS="-O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}" 
MAKEOPTS="-j4" 
VIDEO_CARDS="intel nvidia"' > /mnt/gentoo/etc/portage/make.conf

mirrorselect -s3 -b10 -D >> /mnt/gentoo/etc/portage/make.conf

mkdir --parents /mnt/gentoo/etc/portage/repos.conf

cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

chroot /mnt/gentoo /bin/bash -x <<'EOF'
source /etc/profile
export PS1="(chroot) ${PS1}"

mkdir /boot/efi
mount /dev/sda1 /boot/efi

emerge-webrsync
emerge --sync

eselect profile set 18

emerge -vuDN @world

echo "America/Chicago" > /etc/timezone

emerge --config sys-libs/timezone-data

echo "LANG="en_US.UTF-8"
LC_COLLATE="C"" > /etc/env.d/02locale

env-update && source /etc/profile && export PS1="(chroot) $PS1"

emerge -v sys-kernel/gentoo-sources

emerge -v sys-kernel/genkernel

echo "/dev/sda1	/boot/efi	vfat	noauto,noatime	0 2" > /etc/fstab

genkernel all

emerge -v sys-kernel/linux-firmware

echo "/dev/sda2   /            ext4    noatime              0 1" >> /etc/fstab

echo "hostname="void"" > /etc/conf.d/hostname

cd /etc/init.d 
ln -s net.lo net.wlp3s0
rc-update add net.wlp3s0 default

emerge -v app-admin/sysklogd
rc-update add sysklogd default

emerge -v sys-fs/e2fsprogs
emerge -v sys-fs/dosfstools

emerge -v net-misc/dhcpcd
emerge -v net-wireless/iw net-wireless/wpa_supplicant

echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
emerge -v sys-boot/grub:2
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

exit
EOF

cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot

#!/bin/bash 

# set-up disk partitions
parted --script -a optimal -- /dev/sda \
       mklabel gpt \
       unit mib \
       mkpart primary 1 3 \
       name 1 grub \
       set 1 bios_grub on \
       mkpart primary 3 131 \
       name 2 boot \
       mkpart primary 131 -1 \
       name 3 rootfs

# format new partitions
mkfs.ext2 /dev/sda2
mkfs.ext4 /dev/sda3

# mount root partition
mount /dev/sda3 /mnt/gentoo

# set-up swapfile to use for swap space (instead of swap partition)
dd if=/dev/zero of=/mnt/gentoo/swapfile bs=1MB count=2048
chmod 600 /mnt/gentoo/swapfile
mkswap /mnt/gentoo/swapfile
swapon /mnt/gentoo/swapfile

# network time protocal daemon
ntpd -q -g

# change directory to install stage3
cd /mnt/gentoo

# download stage3 archive
links https://distfiles.gentoo.org

# unarchive stage3
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

# set make parallel job count
echo -e "MAKEOPTS=\"-j$(nproc --all)\"" >> /mnt/gentoo/etc/portage/make.conf

# select 3 fastest mirrors
mirrorselect -s3 -b10 -D >> /mnt/gentoo/etc/portage/make.conf

# configure ebuild repo
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

# copy dns info
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

# mount necessary filesystems
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

# chroot to /mnt/gentoo
chroot /mnt/gentoo /bin/bash -x <<'EOF'
source /etc/profile

# mount /boot partition
mount /dev/sda2 /boot

# create fstab
echo "/dev/sda2      /boot  ext2   defaults,noatime     0 2" > /etc/fstab
echo "/dev/sda3      /      ext4   noatime       0 1" >> /etc/fstab
echo "/swapfile      none   swap   sw,loop       0 0" >> /etc/fstab
echo "tmpfs          /var/tmp/portage     tmpfs  size=4G,uid=portage,gid=portage,mode=775,noatime	0 0" >> /etc/fstab

# mount portage tmpfs - improves emerge time and reduces ssd/hdd wear
mount /var/tmp/portage

# grab latest portage snapshot
emerge-webrsync

# set profile
eselect profile set 16

# set timezone and locale
echo "America/Chicago" > /etc/timezone
emerge --config sys-libs/timezone-data
echo 'LANG="en_US.UTF-8"
LC_COLLATE="C"' > /etc/env.d/02locale

# update environment
env-update && source /etc/profile

# accept non-free linux-fw licenses
echo "sys-kernel/* linux-fw-redistributable no-source-code" > /etc/portage/package.license

# install kernel sources
emerge sys-kernel/gentoo-sources

# set cpu flags
emerge app-portage/cpuid2cpuflags
echo -e "CPU_FLAGS_X86=\"$(cpuid2cpuflags | cut -d':' -f2 | cut -d' ' -f2-)\"" >> /etc/portage/make.conf
emerge -c app-portage/cpuid2cpuflags

# unmask and install genkernel
emerge sys-kernel/genkernel

# auto generate and install linux kernel 
genkernel all

#install optional linux firmware
emerge sys-kernel/linux-firmware

# define a system hostname
echo 'hostname="gentoo"' > /etc/conf.d/hostname

# bring netif up on boot using dhcp
echo 'config_enp0s3="dhcp"' > /etc/conf.d/net
cd /etc/init.d 
ln -s net.lo net.enp0s3
rc-update add net.enp0s3 default

# system logging
emerge app-admin/sysklogd
rc-update add sysklogd default

# install dhcp clinet daemon to obtain ip addr for nic(s)
emerge net-misc/dhcpcd

# install bootloader
emerge sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# setup sudo cmd
emerge app-admin/sudo
groupadd sudo
echo "%sudo ALL=(ALL) ALL" >> /etc/sudoers

# create user account
useradd -m -G sudo -s /bin/bash user

# set default user password (leaving root passwd undefined)
(echo "password"; echo "password") | passwd user

# install misc packages
emerge app-editors/emacs app-misc/ranger www-client/links sys-process/htop

exit
EOF

# unmount chroot env
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo

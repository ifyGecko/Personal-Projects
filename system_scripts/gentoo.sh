#!/bin/bash 

###############################################################
###***ONLY USE GENTOO INSTALLATION MEDIA WITH THIS SCRIPT***###
###############################################################

# set-up disk partitions
parted --script -a optimal -- /dev/sda \
       mklabel gpt \
       unit mib \
       mkpart primary 1 3 \
       name 1 grub \
       set 1 bios_grub on \
       mkpart primary 3 131 \
       name 2 boot \
       mkpart primary 300 -1 \
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
links https://gentoo.org/downloads/

# unarchive stage3
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

# set make parallel job count
echo 'MAKEOPTS="-j4"' >> /mnt/gentoo/etc/portage/make.conf

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
export PS1="(chroot) ${PS1}"

# mount /boot partition
mount /dev/sda2 /boot

# grab latest portage snapshot
emerge-webrsync
emerge --sync

# set hardened profile
eselect profile set 18

# update @world set
emerge -vuDN @world

# set timezone and locale
echo "America/Chicago" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "LANG="en_US.UTF-8"
LC_COLLATE="C"" > /etc/env.d/02locale

# update environment
env-update && source /etc/profile && export PS1="(chroot) $PS1"

# install kernel sources
emerge sys-kernel/gentoo-sources

# set cpu flags
emerge app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

# create fstab
echo "/dev/sda2      /boot  ext2   defaults,noatime     0 2" > /etc/fstab
echo "/dev/sda3      /      ext4   noatime       0 1" >> /etc/fstab
echo "/swapfile      none   swap   sw,loop       0 0" >> /etc/fstab

# install optional firmware
emerge sys-kernel/linux-firmware

### Need to figure out why --autounmask is needed ###
emerge --autounmask-write sys-kernel/genkernel
echo "-3" | etc-update
emerge sys-kernel/genkernel
#####################################################

# auto generate and install linux kernel 
genkernel all

# define a system hostname
echo 'hostname="gentoo"' > /etc/conf.d/hostname

# bring netif up on boot using dhcp
echo 'config_eth0="dhcp"' > /etc/conf.d/net
cd /etc/init.d 
ln -s net.lo net.enp3s0
rc-update add net.enp3s0 default

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

# create user
useradd -m -G users,wheel -s /bin/bash ifyGecko

# set default user password (leaving root passwd undefined)
(echo "password"; echo "password") | passwd ifyGecko


# optional (multiline comment, remove to use)
: '
su - ifyGecko
cd ~/
emerge x11-base/xorg-server
emerge x11-wm/ratpoison
emerge x11-terms/xterm
echo "XTerm*background:BLACK" > .Xdefaults
echo "XTerm*foreground:RED" >> .Xdefaults
echo "startx /usr/bin/ratpoison" > .xinitrc
emerge app-editors/emacs
emerge app-misc/ranger
emerge www-client/links
'

exit
EOF

# unmount chroot env and reboot
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot

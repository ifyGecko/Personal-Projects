#!/bin/bash 

# config variables
export usr='' # new username
export pswd=''
export hostname=''

export e_if='' # wired interface

export w_if='' # wireless interface
export ssid=''
export psk=''

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
mkfs.ext2 -F /dev/sda2
mkfs.ext4 -F /dev/sda3

# mount root partition
mount /dev/sda3 /mnt/gentoo

# set-up swapfile ~20% the size of main memory
dd if=/dev/zero of=/mnt/gentoo/swapfile bs=1MB count=$(bc <<< "scale=0; $(free -m  | grep Mem | awk '{print $2}')*0.2/1")
chmod 600 /mnt/gentoo/swapfile
mkswap /mnt/gentoo/swapfile
swapon /mnt/gentoo/swapfile

# set system time
ntpd -q -g

# change directory to install stage3
cd /mnt/gentoo

# download stage3 archive
links https://gentoo.org/downloads/

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
chroot /mnt/gentoo /bin/bash -x << 'EOF'
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

# add video card to make.conf
echo 'VIDEO_CARDS="intel"' >> /etc/portage/make.conf

# unmask and install genkernel
emerge sys-kernel/genkernel

# auto generate and install linux kernel 
genkernel all

# install additional linux firmware (proprietary firmware)
emerge sys-kernel/linux-firmware

# define a system hostname
echo -e "hostname=\"$hostname\"" > /etc/conf.d/hostname

# set-up wired networking
echo -e "config_$e_if=\"dhcp\"" > /etc/conf.d/net
cd /etc/init.d 
ln -s net.lo net.$e_if

# set-up wireless networking
emerge net-wireless/wpa_supplicant
emerge net-wireless/wireless-tools
cd /etc/init.d
ln -s net.lo net.$w_if

echo -e "modules_$w_if=\"wpa_supplicant\"
wpa_supplicant_$w_if=\"-Dnl80211\"
wpa_timeout_$w_if=30
iwconfig_$w_if_mode=\"Managed\"
dhcpcd_$w_if=\"-t 10\"
config_$w_if=\"dhcp\"" >> /etc/conf.d/net

echo -e "ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1

network={
ssid=\"$ssid\"
psk=\"$psk\"                                                                                                                             
key_mgmt=WPA-PSK                                                                                                                         
}" > /etc/wpa_supplicant/wpa_supplicant.conf

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
useradd -m -G sudo -s /bin/bash $usr

# set default user password (leaving root passwd undefined)
(echo $pswd; echo $pswd) | passwd $usr

# set-up graphical environment
emerge x11-base/xorg-server x11-wm/ratpoison x11-terms/xterm
su - $usr
echo "startx /usr/bin/ratpoison" > .xinitrc
echo "XTerm*background:BLACK
XTerm*foreground:RED
XTerm*eightBitInput:false
XTerm*eightBitInput:true" > .Xdefaults
exit

# firefox
echo 'media-libs/libvpx postproc
dev-db/sqlite secure-delete
dev-lang/python sqlite
media-libs/libpng apn' >> /etc/portage/package.use

mount -o remount,size=7.1G /var/tmp/portage

emerge www-client/firefox

# power management
echo 'app-laptop/laptop-mode-tools acpi
dev-libs/libgcrypt static-libs
dev-libs/libgpg-error static-libs
dev-libs/lzo static-libs' >> /etc/portage/package.use

emerge app-laptop/laptop-mode-tools sys-power/suspend

rc-update add laptop_mode default

# misc tools
emerge www-client/links app-editors/emacs app-misc/ranger sys-block/parted

exit
EOF

# unmount chroot env
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo

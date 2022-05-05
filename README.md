##### This repo hosts instructions for installing Void Linux with UEFI EFISTUB and various post-installation scripts. All of this is tailored for me. You will need to make adjustments if you wish to use something here. Use at your own risk.

## Installing Void Linux with UEFI EFISTUB. 


```

### PRE-INSTALLATION

- SET SHELL
```sh
- $ bash
```

##### Confirm UEFI boot
```sh
- $ ls /sys/firmware/efi    # shows output if it's UEFI
```

Mount point | Partition | Partition type | Suggested size
| --- | --- | --- | --- |
| /mnt/boot | /dev/nvme0n1p1 | EFI system partition | 512 MiB |
| /mnt | /dev/nvme0n1p2 | Linux Filesystem | Remainder of the device |


##### Partition disks
```sh
    - Create partition
        - $ wipefs -af /dev/nvme0n1   # wipe drive
        - $ fdisk /dev/nvme0n1        # use fdisk to partition disk
    - Format parition
        - $ mkfs.vfat /dev/nvme0n1p1
        - $ mkfs.xfs /dev/nvme0n1p2
    - Mount the filesystem
        - $ mount /dev/nvme0n1p2 /mnt
        - $ mkdir /mnt/boot
        - $ mount /dev/nvme0n1p1 /mnt/boot
```

### INSTALLATION

##### Base pkg
```sh
    - $ REPO=https://alpha.de.repo.voidlinux.org/current/
    - $ ARCH=x86_64
    - $ mkdir -p /mnt/var/db/xbps/keys
    - $ cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/   # copy RSA keys
    - $ XBPS_ARCH=$ARCH xbps-install -S -r /mnt -R "$REPO" base-system
```

##### mount pseudo fs
```sh
    - $ mount --rbind /sys /mnt/sys && mount --make-rslave /mnt/sys
    - $ mount --rbind /dev /mnt/dev && mount --make-rslave /mnt/dev
    - $ mount --rbind /proc /mnt/proc && mount --make-rslave /mnt/proc
```

### SYS CONFIG

##### Dns config
```sh
    - $ cp /etc/resolv.conf /mnt/etc/
```

##### Chroot
```sh
    - $ PS1="(chroot)# " chroot /mnt/ /bin/bash
```

##### Add repositories
```sh
    - $ xbps-install -Su void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
    - $ xbps-install -Su
    - $ cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/   # copy mirrors
    - $ xbps-install -Su    # update
```

##### Locale
```sh
    - $ echo "LANG=en_US.UTF-8" > /etc/locale.conf
    - $ echo "LC_COLLATE=C" >> /etc/locale.conf
    - $ echo "en_US.UTF-8 UTF-8" > /etc/default/libc-locales
    - $ xbps-reconfigure -f glibc-locales
```

##### Timezone
```sh
    - $ ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime
    - $ xbps-install -Su neovim
```

##### Hostname
```sh
    - $ echo void > /etc/hostname
```

##### Hosts
```sh
127.0.0.1       localhost
::1             localhost
```

##### Configure rc.conf
```sh
    - $ nvim /etc/rc.conf
    - $ KEYMAP="se-lat6"             # uncomment KEYMAP
```

##### Set root password
```sh
    - $ passwd
```

##### Configure fstab
```sh
    - $ cp /proc/mounts /etc/fstab
    - Delete everything except / and /boot then add tmpfs and efivarfs:
    - Get UUID inside nvim with :r !blkid /dev/nvme0n1p2
    - Set root 0 1
    - Set boot 0 2
    - tmpfs    /tmp    tmpfs   defaults,nosuid,nodev   0 0
    - efivarfs /sys/firmware/efi/efivars   efivarfs    defaults    0 0
    - $ mount efivarfs`
```

##### Dracut
```sh
    - $ nvim /etc/dracut.conf.d/boot.conf
```

```sh
hostonly=yes
hostonly_cmdline=no
use_fstab=yes
compress="cat"
omit_dracutmodules+=" dash i18n rpmversion convertfs btrfs lvm qemu multipatch qemu-net lunmask fstab-sys securityfs biosdevname dmraid dmsquash-live mdraid nbd nfs "
nofscks=yes
no_hostonly_commandline=yes
early_microcode=yes
```

##### Bootloader
```sh
    - $ xbps-install -Su nvidia nvidia-libs nvidia-libs-32bit efibootmgr
    - $ ls /boot    # show kernel version
    - $ efibootmgr -d /dev/nvme0n1 -p Y -c -L "Void" -l /vmlinuz-5.15.36_1 -u \         # Y = partition number.
    - $ 'root=/dev/nvme0n1p2 rw quiet loglevel=0 console=tty2 nvidia-drm.modeset=1 \
    - $ nowatchdog ipv6.disable=1 udev.log_level=3 \
    - $ initrd=\initramfs-5.11.12_1.img' --verbose
```

##### Finalizing steps
```sh
    - $ xbps-query -l | grep linux  # check major and minor; linux5.15
    - $ xbps-reconfigure -fa linux<major>.<minor>
    - $ exit
    - $ umount -R /mnt
    - $ reboot
```

### POST INSTALLATION

##### Add user
```sh
    # enable internet if using dhcpcd
    # if using rc.local no need to do this and just skip to installing zsh and add user.
    - $ ln -sf /etc/sv/dhcpcd /var/service
    - $ xbps-install -S zsh
    - $ useradd -m -G users,wheel,input,video,audio,storage,disk -s /bin/zsh miu
    - $ passwd miu
```

##### Sudo access
```sh
    # edit sudoers
    - $ visudo
    - Exit root and login user
```

### Install pkgs and setup dotfiles

```sh
    - $ sudo xbps-install -Syu git bspwm sxhkd xorg picom kitty ksuperkey rofi xfce4-power-manager polybar lxappearance polkit-gnome elogind firefox mpd mpc ncmpcpp mpv easyeffects
    - $ git clone https://github.com/Miusaky/bspdots.git $HOME
    - $ cd bspdots
    - $ cp --remove-destination -as $HOME/bspdots/. $HOME/
    - $ sudo reboot
```

### MISCELLANEOUS

##### EFI Kernel hook
```sh
    - $ nvim /etc/default/efibootmgr-kernel-hook
```

```sh
# Options for the kernel hook script installed by the efibootmgr package.
MODIFY_EFI_ENTRIES=1
OPTIONS="root=/dev/nvme0n1p2 rw quiet loglevel=0 console=tty2 nvidia-drm.modeset=1 nowatchdog ipv6.disable=1 udev.log_level=3"
DISK="/dev/nvme0n1"
PART=1
```

##### VP
```sh
    - $ git clone https://github.com/void-linux/void-packages.git $HOME/.local/VP
    - $ cd VP
    - $ ./xbps-src binary-bootstrap
    - $ echo XBPS_ALLOW_RESTRICTED=yes >> etc/conf
```

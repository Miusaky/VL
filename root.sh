SCND_UUID=$(blkid -s UUID -o value /dev/nvme1n1p1)

makedir() {
    cd /mnt
    mkdir SCND D1 D2 D3 D4 D5
}

getuuid() {
UUID=$SCND_UUID /mnt/SCND xfs rw,user,exec 0 0 | tee -a /etc/fstab >/dev/null
}

nfs() {
//192.168.1.253/D1/ /mnt/D1 cifs uid=0,credentials=/home/miu/.smb,iocharset=utf8,vers=3.0,file_mode=0777,dir_mode=0777,noperm 0 0 | tee -a /etc/fstab >/dev/null
//192.168.1.253/D2/ /mnt/D2 cifs uid=0,credentials=/home/miu/.smb,iocharset=utf8,vers=3.0,file_mode=0777,dir_mode=0777,noperm 0 0 | tee -a /etc/fstab >/dev/null
//192.168.1.253/D3/ /mnt/D3 cifs uid=0,credentials=/home/miu/.smb,iocharset=utf8,vers=3.0,file_mode=0777,dir_mode=0777,noperm 0 0 | tee -a /etc/fstab >/dev/null
//192.168.1.253/D4/ /mnt/D4 cifs uid=0,credentials=/home/miu/.smb,iocharset=utf8,vers=3.0,file_mode=0777,dir_mode=0777,noperm 0 0 | tee -a /etc/fstab >/dev/null
//192.168.1.253/D5/ /mnt/D5 cifs uid=0,credentials=/home/miu/.smb,iocharset=utf8,vers=3.0,file_mode=0777,dir_mode=0777,noperm 0 0 | tee -a /etc/fstab >/dev/null
}

efikernelhook() {
    cat > /etc/default/efibootmgr-kernel-hook << EOF
MODIFY_EFI_ENTRIES=1
OPTIONS="root=/dev/nvme0n1p2 rw quiet loglevel=0 console=tty2 nvidia-drm.modeset=1 nowatchdog ipv6.disable=1 udev.log_level=3"
DISK="/dev/nvme0n1"
PART=1
EOF
}

postefi() {
    sed -i 's|Void Linux with kernel ${major_version}|Void|g' /etc/kernel.d/post-install/50-efibootmgr
    sed -i 's|Void Linux with kernel ${major_version}|Void|g' /etc/kernel.d/post-remove/50-efibootmgr
}

setulimit() {
    ed -s /etc/security/limits.conf << EOF
    $ i
miu       soft    nofile          1048576
miu       hard    nofile          1048576
.
wq
EOF
}

service() {
    rm -r /var/service/agetty-tty3
    rm -r /var/service/agetty-tty4
    rm -r /var/service/agetty-tty5
    rm -r /var/service/agetty-tty6
    ln -sf /etc/sv/dbus /var/service
    ln -sf /etc/sv/polkitd /var/service
    ln -sf /etc/sv/rpcbind /var/service
    ln -sf /etc/sv/statd /var/service
    ln -sf /etc/sv/ufw /var/service
    ln -sf /etc/sv/netmount /var/service

}

# Make directories to mount the drives in
makedir

# Add data drive to fstab
getuuid

# Add network drives to fstab
nfs

# Set efibootmgr kernel hook
efikernelhook

# Efibootmgr post install and remove
postefi

# Set ulimit for Lutris
setulimit

# Set dbus services
service

echo '\033[0;32mDone. Time to reboot.'

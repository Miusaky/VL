#!/bin/sh

me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
name="$USER"

menu() {
    echo    "usage:         " $me "[OPTION]"
    echo    " "
    echo    "dot:           Install dotfiles"
    echo    "pkg:           Install packages"
    echo    " "
    echo    "finalize       Clean up"
    echo    " "
    echo    "NOTE:  Install dotfiles first. Finalize once all else is done."
}

dot() {
    cd ~
    git clone --bare https://github.com/miusaky/bspdots /home/$name/bspdots
    cp --remove-destination -as /home/$name/bspdots/* /home/$name/
}

pkg() {
    # xorg
    pkgs="xorg-minimal xwininfo xprop xdpyinfo xset xsetroot xrdb nfs-utils rpcbind sv-netmount cifs-utils"
    # nvidia
    pkgs="$pkgs nvidia nvidia-libs nvidia-libs-32bit vulkan-loader vulkan-loader-32bit"
    # core
    pkgs="$pkgs setxkbmap efivar mlocate lm_sensors pkg-config man-db wget zip unzip unrar xz"
    pkgs="$pkgs xdg-user-dirs xtools xdg-utils xclip xdo xdotool elogind dbus ufw"
    # audio
    pkgs="$pkgs pipewire pamixer easyeffects"
    # fonts
    pkgs="$pkgs nerd-fonts"
    # others
    pkgs="$pkgs yt-dlp ffmpeg maim sxiv feh ImageMagick"
    pkgs="$pkgs picom mpd mpc mpv ncmpcpp"
    pkgs="$pkgs zathura zathura-pdf-mupdf"
    pkgs="$pkgs dunst libnotify bottom moreutils jq zenity"
    pkgs="$pkgs qrencode steam lutris"
    pkgs="$pkgs base-devel libXrandr-devel libX11-devel libXft-devel libXinerama-devel"
    # lib32's needed for lutris
    pkgs="$pkgs wine wine-32bit wine-devel wine-devel-32bit wine-mono wine-gecko libmpg123-32bit"
    pkgs="$pkgs libopenal-32bit v4l-utils-32bit libpulseaudio-32bit libjpeg-turbo-32bit libXcomposite-32bit"
    pkgs="$pkgs libXinerama-32bit giflib-32bit ocl-icd ocl-icd-32bit libgpg-error-devel libgpg-error-devel-32bit"
    pkgs="$pkgs sqlite-32bit libpng-32bit readline readline-devel gnutls-devel gnutls-32bit gnutls-devel-32bit"
    pkgs="$pkgs Vulkan-Headers Vulkan-Tools Vulkan-ValidationLayers Vulkan-ValidationLayers-32bit"
    pkgs="$pkgs libwine-32bit libgcrypt-32bit libxslt-32bit libva-32bit gst-plugins-base1-32bit lutris"
    # install pkgs
    sudo xbps-install -Syu $pkgs
}

finalize() {
    rm /home/$name/.bash_logout
    rm /home/$name/.bash_profile
    rm /home/$name/.bashrc
    rm /home/$name/.inputrc
    mkdir -p /home/$name/.config/XDG/MISC
    mkdir -p /home/$name/.config/XDG/DL
    echo '\033[0;32mRun sudo ./root.sh'
}

if [ -n "$1" ]; then
    $1
else
    menu
fi

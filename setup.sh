#!/bin/bash

read -p "Do you want to copy .gitconfig to $HOME? [default: y] (y/n): " user_confirmation
if [ "$user_confirmation" != "n" ]; then
    cp .gitconfig $HOME/.gitconfig
fi

read -p "Do you want to install (symlink) .config folder into $HOME? [default: y] (y/n): " user_confirmation
if [ "$user_confirmation" != "n" ]; then
    # ensure destination exists
    mkdir -p "$HOME/.config"

    # backup directory for any replaced non-symlink entries
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    BACKUP_DIR="$HOME/.config.backup.$TIMESTAMP"

    echo "Installing symlinks from repo .config -> $HOME/.config"

    # iterate over entries in the repo .config (files and directories)
    for entry in .config/*; do
        # skip if glob didn't match
        [ -e "$entry" ] || continue

        name=$(basename "$entry")
        target="$HOME/.config/$name"

        if [ -L "$target" ]; then
            # existing symlink - check where it points
            current_link=$(readlink -f "$target")
            repo_path=$(readlink -f "$entry")
            if [ "$current_link" = "$repo_path" ]; then
                echo "Link for $name already correct, skipping"
                continue
            else
                echo "Updating symlink for $name (was -> $current_link)"
                rm "$target"
            fi
        elif [ -e "$target" ]; then
            # exists and is not a symlink: move to backup
            echo "Backing up existing $target to $BACKUP_DIR/"
            mkdir -p "$BACKUP_DIR"
            mv "$target" "$BACKUP_DIR/"
        fi

        # create symlink
        ln -s "$(pwd)/$entry" "$target"
        echo "Created symlink: $target -> $(pwd)/$entry"
    done

    # fix ownership of the files in $HOME/.config (follow symlinks)
    sudo chown -R $USER:$(id -g $USER) "$HOME/.config"
fi

# Install custom workspace-icons font
read -p "Do you want to install the workspace-icons font? [default: y] (y/n): " user_confirmation
if [ "$user_confirmation" != "n" ]; then
    mkdir -p "$HOME/.local/share/fonts"
    cp .config/waybar/fonts/workspace-icons.ttf "$HOME/.local/share/fonts/"
    fc-cache -fv
    echo "workspace-icons font installed"
fi

# Symlink Obsidian CSS snippets into vault
read -p "Do you want to symlink Obsidian CSS snippets into your vault? [default: y] (y/n): " user_confirmation
if [ "$user_confirmation" != "n" ]; then
    OBSIDIAN_SNIPPETS="$HOME/repos/notes/notes/.obsidian/snippets"
    mkdir -p "$OBSIDIAN_SNIPPETS"

    for snippet in .config/obsidian/snippets/*.css; do
        [ -e "$snippet" ] || continue

        name=$(basename "$snippet")
        target="$OBSIDIAN_SNIPPETS/$name"

        if [ -L "$target" ]; then
            current_link=$(readlink -f "$target")
            repo_path=$(readlink -f "$snippet")
            if [ "$current_link" = "$repo_path" ]; then
                echo "Snippet $name already linked, skipping"
                continue
            else
                echo "Updating snippet symlink for $name"
                rm "$target"
            fi
        elif [ -e "$target" ]; then
            echo "Backing up existing $target"
            mv "$target" "$target.bak"
        fi

        ln -s "$(pwd)/$snippet" "$target"
        echo "Linked snippet: $target -> $(pwd)/$snippet"
    done
    echo "Enable snippets in Obsidian: Settings > Appearance > CSS snippets"
fi

# Install all packages using paru (AUR helper + pacman interface)
read -p "Do you want to update, upgrade and install all required packages? [default: y] (y/n): " user_confirmation
if [ "$user_confirmation" != "n" ]; then
    packages=(
        # CachyOS base & meta-packages
        accountsservice
        base
        base-devel
        bash-completion
        cachyos-fish-config
        cachyos-hello
        cachyos-hooks
        cachyos-hyprland-settings
        cachyos-kernel-manager
        cachyos-keyring
        cachyos-micro-settings
        cachyos-mirrorlist
        cachyos-nord-gtk-theme-git
        cachyos-packageinstaller
        cachyos-plymouth-theme
        cachyos-rate-mirrors
        cachyos-settings
        cachyos-v3-mirrorlist
        cachyos-v4-mirrorlist
        cachyos-wallpapers
        cachyos-zsh-config
        capitaine-cursors
        chwd
        haveged
        logrotate
        lsb-release
        man-db
        man-pages
        mkinitcpio
        octopi
        paru
        perl
        plymouth
        rebuild-detector
        reflector
        sudo
        texinfo

        # Kernel & hardware
        amd-ucode
        cpupower
        dmidecode
        hdparm
        hwdetect
        hwinfo
        lib32-mesa
        lib32-opencl-rusticl-mesa
        lib32-openssl-1.1
        lib32-vulkan-radeon
        linux-cachyos
        linux-cachyos-headers
        linux-firmware
        mesa-utils
        opencl-rusticl-mesa
        power-profiles-daemon
        sof-firmware
        sysfsutils
        upower
        vulkan-radeon

        # Filesystem & disk
        btrfs-assistant
        btrfs-progs
        cryptsetup
        device-mapper
        dmraid
        dosfstools
        e2fsprogs
        efibootmgr
        efitools
        exfatprogs
        f2fs-tools
        fsarchiver
        jfsutils
        lvm2
        mdadm
        mtools
        nilfs-utils
        smartmontools
        snapper
        systemd-boot-manager
        xfsprogs

        # Networking
        bind
        dhclient
        dnsmasq
        ethtool
        inetutils
        iptables-nft
        iwd
        modemmanager
        netctl
        networkmanager
        networkmanager-openvpn
        nfs-utils
        nss-mdns
        ntp
        openssh
        rsync
        s-nail
        ufw
        usb_modeswitch
        usbutils
        wireguard-tools
        wireless-regdb
        wpa_supplicant
        xl2tpd
        cifs-utils
        sshfs

        # Audio & media
        alsa-firmware
        alsa-plugins
        alsa-utils
        ffmpegthumbnailer
        gst-libav
        gst-plugin-pipewire
        gst-plugins-bad
        gst-plugins-ugly
        libdvdcss
        pamixer
        pavucontrol
        pipewire-alsa
        pipewire-pulse
        rtkit
        wireplumber

        # Bluetooth
        bluez
        bluez-hid2hci
        bluez-libs
        bluez-utils
        bluetooth-tui

        # Printing
        cups
        cups-filters
        cups-pdf
        foomatic-db
        foomatic-db-engine
        foomatic-db-gutenprint-ppds
        foomatic-db-nonfree
        foomatic-db-nonfree-ppds
        foomatic-db-ppds
        ghostscript
        gsfonts
        gutenprint
        hplip
        naps2-bin
        splix
        system-config-printer

        # Fonts
        adobe-source-han-sans-cn-fonts
        adobe-source-han-sans-jp-fonts
        adobe-source-han-sans-kr-fonts
        awesome-terminal-fonts
        noto-color-emoji-fontconfig
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        opendesktop-fonts
        ttf-bitstream-vera
        ttf-dejavu
        ttf-firacode-nerd
        ttf-liberation
        ttf-meslo-nerd
        ttf-opensans

        # Xorg & display
        sddm
        xf86-input-libinput
        xf86-video-amdgpu
        xorg-server
        xorg-xdpyinfo
        xorg-xinit
        xorg-xinput
        xorg-xkill
        xorg-xrandr
        xorg-xwayland

        # Hyprland & Wayland DE
        bemenu
        bemenu-wayland
        grimblast-git
        hyprland
        kvantum
        kvantum-theme-nordic-git
        mako
        polkit-kde-agent
        rofi-emoji
        slurp
        swappy
        swaybg
        swaylock-effects-git
        swaylock-fancy-git
        waybar
        wl-clipboard
        wlogout
        wob
        wofi
        xdg-desktop-portal-hyprland
        xdg-user-dirs
        qt5ct
        qt5-wayland

        # CLI tools & utilities
        btop
        diffutils
        duf
        eza
        fd
        fzf
        glances
        less
        micro
        nano
        nano-syntax-highlighting
        pacman-contrib
        plocate
        pv
        ripgrep
        socat
        wget
        which
        zip
        unzip
        zoxide

        # Development
        claude-code
        docker
        docker-compose
        git
        git-credential-manager
        lazydocker
        lazygit
        npm
        nvim
        python
        python-defusedxml
        python-packaging
        python-pyqt5
        python-reportlab
        vi
        vim
        zed
        visual-studio-code-bin

        # Desktop applications
        alacritty
        betterbird-bin
        bitwarden
        discord
        libreoffice-still
        obsidian-bin
        ungoogled-chromium-bin
        zen-browser-bin

        # Libraries
        libgsf
        libopenraw
        libwnck3
        poppler-glib
        webkit2gtk-4.1
        sg3_utils
        lsscsi
    )

    paru -Syu --needed "${packages[@]}"
fi

# optional: install rustup
read -p "Do you want to install rustup? [default: y] (y/n): " rustup_installed
if [ "$rustup_installed" != "n" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# optional: enable docker service
read -p "Do you want to setup docker now? [default: y] (y/n): " user_confirmation
if [ "$user_confirmation" != "n" ]; then
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
fi

# optional: enable wireguard kernel module
read -p "Do you want to enable the wireguard kernel module? [default: y] (y/n): " user_confirmation
if [ "$user_confirmation" != "n" ]; then
    sudo modprobe wireguard
fi

# This will create a credentials file (~/.smbcredentials), secure it,
# add an /etc/fstab entry for e.g. //192.168.178.130/NetworkDrive and test mounting.
read -p "Do you want to add a permanent CIFS mount for //192.168.178.130/NetworkDrive? [default: y] (y/n): " user_confirmation
if [ "$user_confirmation" != "n" ]; then
    # ask for mount point and share details, provide sensible defaults
    MOUNT_POINT=/mnt/networkdrive
    SHARE=//192.168.178.130/NetworkDrive
    read -p "Mount point [default: $MOUNT_POINT]: " tmp
    if [ -n "$tmp" ]; then
        MOUNT_POINT=$tmp
    fi
    read -p "Network share [default: $SHARE]: " tmp
    if [ -n "$tmp" ]; then
        SHARE=$tmp
    fi

    sudo mkdir -p "$MOUNT_POINT"

    # prompt for username and create credentials file
    read -p "SMB username [default: root]: " SMB_USER
    if [ -z "$SMB_USER" ]; then
        SMB_USER=root
    fi

    CRED_FILE="$HOME/.smbcredentials"
    echo "This will create $CRED_FILE with username=$SMB_USER and a password you enter now."
    # read password silently
    while true; do
        read -s -p "Enter SMB password for user '$SMB_USER': " SMB_PASS
        echo
        read -s -p "Confirm SMB password: " SMB_PASS2
        echo
        if [ "$SMB_PASS" = "$SMB_PASS2" ]; then
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done

    # write credentials file
    printf "username=%s\npassword=%s\n" "$SMB_USER" "$SMB_PASS" > "$CRED_FILE"
    chmod 600 "$CRED_FILE"

    # add fstab entry if it doesn't already exist
    FSTAB_LINE="$SHARE $MOUNT_POINT cifs uid=$(id -u),gid=$(id -g),credentials=$CRED_FILE,rw,iocharset=utf8 0 0"
    if ! grep -Fxq "$FSTAB_LINE" /etc/fstab 2>/dev/null; then
        echo "Adding fstab entry. You may be prompted for sudo password to edit /etc/fstab"
        # backup fstab first
        sudo cp /etc/fstab /etc/fstab.bak-$(date +%Y%m%d%H%M%S)
        # append the fstab line
        printf "%s\n" "$FSTAB_LINE" | sudo tee -a /etc/fstab >/dev/null
    else
        echo "An identical fstab entry already exists; skipping append."
    fi

    # test the mount
    echo "Testing mounts with: sudo mount -a"
    if sudo mount -a; then
        echo "Mount succeeded. $SHARE is mounted at $MOUNT_POINT (if available)."
        sudo systemctl daemon-reload
    else
        echo "Mount failed. Check /var/log/syslog or journalctl -xe for details and verify credentials/share." >&2
    fi
fi


# warn user if ufw is not enabled
ufw status | grep "Status: inactive" > /dev/null
if [ $? -eq 0 ]; then
    echo "\e[93mWarning: ufw is not enabled.\e[0m"
fi

echo "\e[92mSetup complete. You might want to reboot once to make sure all changes are applied.\e[0m"

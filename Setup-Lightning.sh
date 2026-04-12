#!/bin/bash

# =================================================================
# LIGHTNING-OS V3.6.6 - FINAL STABLE (Ultimate Edition + Lockdown)
# =================================================================

# === SYSTEM LOGOW (CZARNA SKRZYNKA) ===
mkdir -p "$HOME/Pulpit"
LOG_FILE="$HOME/Pulpit/Lightning_Setup_Log_$(date +%Y%m%d_%H%M%S).txt"
exec > >(tee -i "$LOG_FILE") 2>&1

echo "================================================================="
echo " START INSTALACJI LIGHTNING-OS (Log zapisywany do: $LOG_FILE)"
echo "================================================================="

clear
echo "Inicjalizacja Lightning-OS V3.6.6..."

# 1. STRUKTURA /OPT/
sudo mkdir -p /opt/lightning-os/shaders
sudo chown -R $USER:$USER /opt/lightning-os

cp -f ./Lossless.dll /opt/lightning-os/lossless.dll
cp -f ./DDraw.dll /opt/lightning-os/ddraw.dll
cp -f ./Lightning-Core.sh /opt/lightning-os/Lightning-Core.sh
cp -f ./DXVk.conf /opt/lightning-os/dxvk.conf
cp -f ./ikona.png /opt/lightning-os/icon.png

# 2. INSTALACJA PAKIETOW
sudo pacman -S --noconfirm --needed \
    firefox-developer-edition lsfg-vk steam lact bc cpupower \
    nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils \
    downgrade winetricks mangohud lib32-mangohud ntfs-3g ananicy-cpp gamemode lib32-gamemode yad notify-osd

# 3. KONFIGURACJA BAZOWEGO WINE
sudo downgrade wine-staging --latest wine-staging=11.4 --ignore never
mkdir -p ~/.wine/drive_c/windows/system32
ln -sf /opt/lightning-os/lossless.dll ~/.wine/drive_c/windows/system32/lossless.dll
ln -sf /opt/lightning-os/ddraw.dll ~/.wine/drive_c/windows/system32/ddraw.dll
wine regedit /c ./User.reg
cp -f /opt/lightning-os/dxvk.conf ~/.wine/dxvk.conf

# 4. INSTALACJA BIBLIOTEK (ALL-IN-ONE)
WINEPREFIX=~/.wine winetricks -q corefonts d3dx9 d3dx10 d3dx11_43 dotnet48 physx
for pkg in vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun2022; do
    WINEPREFIX=~/.wine winetricks -q --force $pkg
done

# 5. NAPRAWA I AUTO-MONTOWANIE DYSKU RZECZY
echo "Konfiguracja dysku RZECZY..."
DISK_UUID=$(lsblk -no UUID,LABEL | grep "RZECZY" | awk '{print $1}')

if [ -n "$DISK_UUID" ]; then
    echo "Znaleziono dysk RZECZY (UUID: $DISK_UUID). Naprawiam fstab..."
    sudo sed -i '/RZECZY/d' /etc/fstab 
    echo "UUID=$DISK_UUID /mnt/RZECZY ntfs-3g defaults,nofail,big_writes,remove_hiberfile,uid=1000,gid=1000,dmask=002,fmask=113 0 0" | sudo tee -a /etc/fstab
    
    sudo mkdir -p /mnt/RZECZY
    sudo umount /dev/disk/by-uuid/$DISK_UUID 2>/dev/null
    sudo ntfsfix -d /dev/disk/by-uuid/$DISK_UUID
else
    echo "UWAGA: Linux sprzetowo nie widzi dysku RZECZY! Sprawdz wpiecie kabli lub czy Windows go nie zamrozil."
fi

# 6. KONFIGURACJA /ETC/ENVIRONMENT
sudo bash -c 'cat <<EOF > /etc/environment
__NV_PRIME_RENDER_OFFLOAD=1
__GLX_VENDOR_LIBRARY_NAME=nvidia
DXVK_STATE_CACHE=1
DXVK_STATE_CACHE_PATH=/opt/lightning-os/shaders
__GL_SHADER_DISK_CACHE=1
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
__GL_SHADER_DISK_CACHE_PATH=/opt/lightning-os/shaders
PROTON_ENABLE_NVAPI=1
PROTON_HIDE_NVIDIA_GPU=0
EOF'

# 7. CENTRUM STEROWANIA LIGHTNING-OS
echo "Konfiguracja panelu sterowania LSFG..."

cat << 'EOF' | sudo tee /usr/bin/lightning-control > /dev/null
#!/bin/bash

CONF_DIR="$HOME/.config/lightning-os"
CONF_FILE="$CONF_DIR/settings.env"

mkdir -p "$CONF_DIR"
if [ ! -f "$CONF_FILE" ]; then
    echo -e "export LS_MULTIPLIER=2\nexport MANGOHUD=1" > "$CONF_FILE"
fi

if [ "$1" == "turbo" ]; then
    sed -i 's/export LS_MULTIPLIER=.*/export LS_MULTIPLIER=2/' "$CONF_FILE"
    sed -i 's/export MANGOHUD=.*/export MANGOHUD=1/' "$CONF_FILE"
    notify-send "Lightning-OS" "Aktywowano: TRYB TURBO"
elif [ "$1" == "classic" ]; then
    sed -i 's/export LS_MULTIPLIER=.*/export LS_MULTIPLIER=0/' "$CONF_FILE"
    sed -i 's/export MANGOHUD=.*/export MANGOHUD=0/' "$CONF_FILE"
    notify-send "Lightning-OS" "Aktywowano: TRYB CLASSIC"
else
    export GDK_BACKEND=x11
    
    if grep -q "export LS_MULTIPLIER=2" "$CONF_FILE"; then
        yad --title="Lightning-OS" --width=300 --center \
            --window-icon="preferences-desktop-gaming" \
            --image="preferences-desktop-gaming" \
            --text="Wybierz tryb wydajnosci:\n(Obecnie dziala: TURBO)" \
            --button="[WLACZONY] TURBO:10" --button="CLASSIC:20"
    else
        yad --title="Lightning-OS" --width=300 --center \
            --window-icon="preferences-desktop-gaming" \
            --image="preferences-desktop-gaming" \
            --text="Wybierz tryb wydajnosci:\n(Obecnie dziala: CLASSIC)" \
            --button="TURBO:10" --button="[WLACZONY] CLASSIC:20"
    fi
    
    case $? in
        10) /usr/bin/lightning-control turbo ;;
        20) /usr/bin/lightning-control classic ;;
    esac
fi
EOF

sudo chmod +x /usr/bin/lightning-control

rm -f ~/.config/autostart/lightning-control.desktop

cat << 'EOF' | sudo tee /usr/share/applications/lightning-control.desktop > /dev/null
[Desktop Entry]
Name=Lightning-OS Control
Comment=Zarzadzaj wydajnoscia LSFG
Exec=/usr/bin/lightning-control
Icon=preferences-desktop-gaming
Terminal=false
Type=Application
Categories=Game;Settings;
Actions=Turbo;Classic;

[Desktop Action Turbo]
Name=Wlacz TRYB TURBO
Exec=/usr/bin/lightning-control turbo

[Desktop Action Classic]
Name=Wlacz TRYB CLASSIC
Exec=/usr/bin/lightning-control classic
EOF

update-desktop-database /usr/share/applications/ 2>/dev/null

# 8. LIGHTNING WINE LOADER & MENU KONTEKSTOWE
echo "Integracja narzedzi dla plikow exe..."

mkdir -p ~/.local/share/applications
cat << 'EOF' > ~/.local/share/applications/lightning-wine.desktop
[Desktop Entry]
Name=Lightning-OS Wine Loader
Exec=env WINEDLLOVERRIDES="d2d1=d" lightning-run wine "%f"
Type=Application
Terminal=false
Icon=wine
MimeType=application/x-ms-dos-executable;application/x-msi;application/x-ms-shortcut;
EOF

update-desktop-database ~/.local/share/applications/ 2>/dev/null

mkdir -p ~/.local/share/kio/servicemenus/
cat << 'EOF' > ~/.local/share/kio/servicemenus/lightning-silent-install.desktop
[Desktop Entry]
Type=Service
MimeType=application/x-ms-dos-executable;
Actions=SilentInstall;
Icon=wine

[Desktop Action SilentInstall]
Name=Zainstaluj cicho (GOG/InnoSetup)
Icon=system-run
Exec=env WINEDLLOVERRIDES="d2d1=d" lightning-run wine "%f" /VERYSILENT
EOF

# 9. GAMEMODE & ANANICY
mkdir -p ~/.config/gamemode
cat <<EOF > ~/.config/gamemode/gamemode.ini
[custom]
start=lightning start
end=lightning stop
EOF
sudo systemctl enable --now ananicy-cpp

# 10. UNIWERSALNY WRAPPER
echo "Tworzenie glownego silnika uruchomieniowego..."
sudo bash -c 'cat << '\''EOF'\'' > /usr/bin/lightning-run
#!/bin/bash
if [ -n "$STEAM_COMPAT_DATA_PATH" ]; then
    PREFIX_PATH="$STEAM_COMPAT_DATA_PATH/pfx"
elif [ -n "$WINEPREFIX" ]; then
    PREFIX_PATH="$WINEPREFIX"
else
    PREFIX_PATH="$HOME/.wine"
fi

SYS32="$PREFIX_PATH/drive_c/windows/system32"
if [ -d "$PREFIX_PATH" ]; then
    mkdir -p "$SYS32"
    ln -sf /opt/lightning-os/lossless.dll "$SYS32/lossless.dll"
    ln -sf /opt/lightning-os/ddraw.dll "$SYS32/ddraw.dll"
fi

CONF_FILE="$HOME/.config/lightning-os/settings.env"
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
else
    export LS_MULTIPLIER=2
    export MANGOHUD=1
fi

export PROTON_USE_FSYNC=1
export PROTON_USE_ESYNC=1
export WINEDLLOVERRIDES="ddraw=n,b;lossless=n,b"

if [ "$LS_MULTIPLIER" == "2" ]; then
    export VK_INSTANCE_LAYERS=VK_LAYER_LS_frame_generation
    export LS_DLL_PATH="/opt/lightning-os/lossless.dll"
    exec gamemoderun mangohud "$@"
else
    unset VK_INSTANCE_LAYERS
    unset LS_DLL_PATH
    exec gamemoderun "$@"
fi
EOF'

sudo chmod +x /usr/bin/lightning-run

# 11. TARCZA SYSTEMOWA (IGNORE PKG)
sudo sed -i '/^#IgnorePkg/ s/^#//' /etc/pacman.conf
for pkg in wine-staging nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils nvidia nvidia-dkms; do
    if ! grep -q "IgnorePkg.*$pkg" /etc/pacman.conf; then
        sudo sed -i "/^IgnorePkg/ s/$/ $pkg/" /etc/pacman.conf
    fi
done

# 12. LOCKDOWN ZASILANIA I EKRANU
echo "Wylaczanie usypiania, hibernacji i wylogowywania..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false 2>/dev/null
kwriteconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key suspendType 0 2>/dev/null
xset s off 2>/dev/null || true
xset -dpms 2>/dev/null || true

# 13. MODUŁ KOSMETYCZNY (Zewnetrzne wywolanie OOP)
echo "Uruchamianie modulu wizualnego..."
if [ -f "./Apply-Cosmetics.sh" ]; then
    chmod +x ./Apply-Cosmetics.sh
    bash ./Apply-Cosmetics.sh
else
    echo "UWAGA: Nie znaleziono pliku Apply-Cosmetics.sh, pomijam kosmetyke."
fi

# 14. FINISZ I AUTO-REBOOT
mkdir -p ~/.config/MangoHud
cp -f ./MangoHUD.conf ~/.config/MangoHud/MangoHud.conf
sudo mkinitcpio -P

echo "========================================="
echo "  LIGHTNING-OS V3.6.6 GOTOWY!"
echo "  System zrestartuje sie za 3 sekundy..."
echo "========================================="
sleep 3
sudo reboot
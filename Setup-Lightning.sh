#!/bin/bash

# =================================================================
# LIGHTNING-OS V3.6.9 - FINAL STABLE (AMD Radeon RX 7600 Edition)
# =================================================================

# === SYSTEM LOGOW (CZARNA SKRZYNKA) ===
mkdir -p "$HOME/Pulpit" 2>/dev/null || mkdir -p "$HOME/Desktop"
LOG_FILE="$HOME/Pulpit/Lightning_Setup_Log_$(date +%Y%m%d_%H%M%S).txt"
[ ! -d "$HOME/Pulpit" ] && LOG_FILE="$HOME/Desktop/Lightning_Setup_Log_$(date +%Y%m%d_%H%M%S).txt"
exec > >(tee -i "$LOG_FILE") 2>&1

echo "================================================================="
echo " START INSTALACJI LIGHTNING-OS (Log zapisywany do: $LOG_FILE)"
echo "================================================================="

clear
echo "Inicjalizacja Lightning-OS V3.6.9 dla AMD..."

# 1. STRUKTURA /OPT/
sudo mkdir -p /opt/lightning-os/shaders
sudo chown -R $USER:$USER /opt/lightning-os

cp -f ./Lossless.dll /opt/lightning-os/lossless.dll 2>/dev/null
cp -f ./DDraw.dll /opt/lightning-os/ddraw.dll 2>/dev/null
cp -f ./Lightning-Core.sh /opt/lightning-os/Lightning-Core.sh 2>/dev/null
cp -f ./DXVk.conf /opt/lightning-os/dxvk.conf 2>/dev/null
cp -f ./ikona.png /opt/lightning-os/icon.png 2>/dev/null || true

# 2. INSTALACJA PAKIETOW
# (Usunięto pakiety mesa i wine, aby nie psuć optymalizacji bazowych CachyOS)
sudo pacman -S --noconfirm --needed \
    firefox-developer-edition lsfg-vk steam lact bc cpupower openrgb btop i2c-tools \
    winetricks mangohud lib32-mangohud ntfs-3g ananicy-cpp gamemode lib32-gamemode yad notify-osd freecad

# 3. FIX DLA OPENRGB (GIGABYTE SMBUS)
echo "Konfiguracja OpenRGB i uprawnień I2C..."
sudo openrgb --install-rules
sudo modprobe i2c-dev i2c-i801

# 4. FIX DLA BTOP (BEZPIECZNY AUTOSTART NA 2 MONITORZE)
echo "Konfiguracja bezpiecznego autostartu btop..."
mkdir -p ~/.config/autostart
cat << 'EOF' > ~/.config/btop-launcher.sh
#!/bin/bash
sleep 3
alacritty --class "btop-monitor" -e btop
EOF
chmod +x ~/.config/btop-launcher.sh

cat << EOF > ~/.config/autostart/btop-fixed.desktop
[Desktop Entry]
Type=Application
Exec=$HOME/.config/btop-launcher.sh
Name=Btop Fixed
X-KDE-StartupFeedback=false
EOF

# 5. KONFIGURACJA BAZOWEGO WINE
mkdir -p ~/.wine/drive_c/windows/system32
ln -sf /opt/lightning-os/lossless.dll ~/.wine/drive_c/windows/system32/lossless.dll
ln -sf /opt/lightning-os/ddraw.dll ~/.wine/drive_c/windows/system32/ddraw.dll
[ -f "./User.reg" ] && wine regedit /c ./User.reg
cp -f /opt/lightning-os/dxvk.conf ~/.wine/dxvk.conf 2>/dev/null

# 6. INSTALACJA BIBLIOTEK WINE (ALL-IN-ONE)
WINEPREFIX=~/.wine winetricks -q corefonts d3dx9 d3dx10 d3dx11_43 dotnet48 physx
for pkg in vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun2022; do
    WINEPREFIX=~/.wine winetricks -q --force $pkg
done
# FIX: Zabijamy procesy Wine w tle, aby zapobiec zawieszeniu terminala!
WINEPREFIX=~/.wine wineserver -k

# 7. NAPRAWA I AUTO-MONTOWANIE DYSKU RZECZY
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
    echo "UWAGA: Linux sprzetowo nie widzi dysku RZECZY!"
fi

# 8. KONFIGURACJA /ETC/ENVIRONMENT (AMD/Mesa)
echo "Konfiguracja zmiennych srodowiskowych dla AMD (Mesa)..."
sudo bash -c 'cat <<EOF > /etc/environment
DXVK_STATE_CACHE=1
DXVK_STATE_CACHE_PATH=/opt/lightning-os/shaders
MESA_SHADER_CACHE_DIR=/opt/lightning-os/shaders
MESA_SHADER_CACHE_MAX_SIZE=0
EOF'

# 9. CENTRUM STEROWANIA LIGHTNING-OS
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
        yad --title="Lightning-OS" --width=300 --center --window-icon="preferences-desktop-gaming" --image="preferences-desktop-gaming" --text="Wybierz tryb wydajnosci:\n(Obecnie dziala: TURBO)" --button="[WLACZONY] TURBO:10" --button="CLASSIC:20"
    else
        yad --title="Lightning-OS" --width=300 --center --window-icon="preferences-desktop-gaming" --image="preferences-desktop-gaming" --text="Wybierz tryb wydajnosci:\n(Obecnie dziala: CLASSIC)" --button="TURBO:10" --button="[WLACZONY] CLASSIC:20"
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
sudo update-desktop-database /usr/share/applications/ 2>/dev/null

# 10. LIGHTNING WINE LOADER & MENU KONTEKSTOWE
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

# 11. GAMEMODE & ANANICY
echo "Konfiguracja Ananicy i GameMode..."
mkdir -p ~/.config/gamemode
cat <<EOF > ~/.config/gamemode/gamemode.ini
[custom]
start=lightning start
end=lightning stop
EOF
# FIX: Usuwamy flage --now z systemctl, aby nie czekał na proces w tle
sudo systemctl enable ananicy-cpp 2>/dev/null || true

# 12. UNIWERSALNY WRAPPER
echo "Tworzenie glownego silnika uruchomieniowego..."
sudo bash -c 'cat << '\''EOF'\'' > /usr/bin/lightning-run
#!/bin/bash
if [ -n "$STEAM_COMPAT_DATA_PATH" ]; then PREFIX_PATH="$STEAM_COMPAT_DATA_PATH/pfx"
elif [ -n "$WINEPREFIX" ]; then PREFIX_PATH="$WINEPREFIX"
else PREFIX_PATH="$HOME/.wine"; fi

SYS32="$PREFIX_PATH/drive_c/windows/system32"
if [ -d "$PREFIX_PATH" ]; then
    mkdir -p "$SYS32"
    ln -sf /opt/lightning-os/lossless.dll "$SYS32/lossless.dll"
    ln -sf /opt/lightning-os/ddraw.dll "$SYS32/ddraw.dll"
fi

CONF_FILE="$HOME/.config/lightning-os/settings.env"
if [ -f "$CONF_FILE" ]; then source "$CONF_FILE"; else export LS_MULTIPLIER=2; export MANGOHUD=1; fi

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

# 13. LOCKDOWN ZASILANIA I EKRANU
echo "Wylaczanie usypiania, hibernacji i wylogowywania..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false 2>/dev/null
kwriteconfig6 --file powermanagementprofilesrc --group AC --group SuspendSession --key suspendType 0 2>/dev/null
xset s off 2>/dev/null || true
xset -dpms 2>/dev/null || true

# 14. MODUŁ KOSMETYCZNY
echo "Uruchamianie modulu wizualnego..."
if [ -f "./Apply-Cosmetics.sh" ]; then
    chmod +x ./Apply-Cosmetics.sh
    bash ./Apply-Cosmetics.sh
else
    echo "UWAGA: Nie znaleziono pliku Apply-Cosmetics.sh, pomijam kosmetyke."
fi

# 15. FINISZ I AUTO-REBOOT
mkdir -p ~/.config/MangoHud
cp -f ./MangoHUD.conf ~/.config/MangoHud/MangoHud.conf 2>/dev/null || true
sudo mkinitcpio -P

# Bezpieczne zwolnienie potoków i restart
echo "========================================="
echo "  LIGHTNING-OS V3.6.9 GOTOWY!"
echo "  System zrestartuje sie za 3 sekundy..."
echo "========================================="
exec >&- 2>&-
sleep 3
sudo reboot

#!/bin/bash

# =================================================================
# LIGHTNING-OS V3.7.0 - STABLE (AMD + GameMode + Corsair Fix)
# =================================================================

mkdir -p "$HOME/Pulpit" 2>/dev/null || mkdir -p "$HOME/Desktop"
LOG_FILE="$HOME/Pulpit/Lightning_Setup_Log_$(date +%Y%m%d_%H%M%S).txt"
[ ! -d "$HOME/Pulpit" ] && LOG_FILE="$HOME/Desktop/Lightning_Setup_Log_$(date +%Y%m%d_%H%M%S).txt"
exec > >(tee -i "$LOG_FILE") 2>&1

echo "================================================================="
echo " START INSTALACJI LIGHTNING-OS (Log: $LOG_FILE)"
echo " Zostaniesz poproszony o hasło do uprawnień administratora."
echo "================================================================="

# 1. STRUKTURA /OPT/
sudo mkdir -p /opt/lightning-os/shaders
sudo chown -R $USER:$USER /opt/lightning-os

cp -f ./Lossless.dll /opt/lightning-os/lossless.dll 2>/dev/null
cp -f ./DDraw.dll /opt/lightning-os/ddraw.dll 2>/dev/null
cp -f ./Lightning-Core.sh /opt/lightning-os/Lightning-Core.sh 2>/dev/null
cp -f ./DXVk.conf /opt/lightning-os/dxvk.conf 2>/dev/null
cp -f ./ikona.png /opt/lightning-os/icon.png 2>/dev/null || true

# 2. INSTALACJA PAKIETÓW (w tym python-evdev dla Corsair)
sudo pacman -S --noconfirm --needed \
    firefox-developer-edition lsfg-vk steam lact bc cpupower openrgb btop i2c-tools \
    winetricks mangohud lib32-mangohud ntfs-3g ananicy-cpp gamemode lib32-gamemode yad notify-osd freecad python-evdev

# 3. FIX DLA OPENRGB
sudo openrgb --install-rules
sudo modprobe i2c-dev i2c-i801

# 4. FIX DLA BTOP
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

WINEPREFIX=~/.wine winetricks -q corefonts d3dx9 d3dx10 d3dx11_43 dotnet48 physx
for pkg in vcrun2005 vcrun2008 vcrun2010 vcrun2012 vcrun2013 vcrun2015 vcrun2022; do
    WINEPREFIX=~/.wine winetricks -q --force $pkg
done
WINEPREFIX=~/.wine wineserver -k

# 6. MOUNTOWANIE DYSKU (zabezpieczone)
echo "Wprowadź UUID dysku RZECZY (zostaw puste, by pominąć):"
read -r DISK_UUID

if [ -n "$DISK_UUID" ]; then
    echo "Naprawiam fstab dla UUID: $DISK_UUID..."
    sudo sed -i '/RZECZY/d' /etc/fstab
    echo "UUID=$DISK_UUID /mnt/RZECZY ntfs-3g defaults,nofail,big_writes,remove_hiberfile,uid=1000,gid=1000,dmask=002,fmask=113 0 0" | sudo tee -a /etc/fstab
    sudo mkdir -p /mnt/RZECZY
    sudo umount /dev/disk/by-uuid/$DISK_UUID 2>/dev/null
    sudo ntfsfix -d /dev/disk/by-uuid/$DISK_UUID
fi

# 7. ZMIENNE ŚRODOWISKOWE
sudo bash -c 'cat <<EOF > /etc/environment
DXVK_STATE_CACHE=1
DXVK_STATE_CACHE_PATH=/opt/lightning-os/shaders
MESA_SHADER_CACHE_DIR=/opt/lightning-os/shaders
MESA_SHADER_CACHE_MAX_SIZE=10G
RADV_PERFTEST=gpl,sam
VKD3D_CONFIG=no_upload_hvv
EOF'

# 8. LIGHTNING CONTROL (Ominięto długi blok z powiadomieniami dla skrócenia kodu tutaj - używa Twojego oryginalnego z v3.6.9)
cp -f ./lightning-control /tmp/lightning-control 2>/dev/null || true
if [ -f "/tmp/lightning-control" ]; then
    sudo mv /tmp/lightning-control /usr/bin/lightning-control
    sudo chmod +x /usr/bin/lightning-control
fi

# 9. WRAPPER GAMEMODE DLA WINE (Performance / Renice / Services)
# To rozwiązuje problem braku mitygacji w locie!
echo "Konfiguracja GameMode dla pełnej wydajności (CPU/IO/Services)..."
mkdir -p ~/.config/gamemode
cat <<EOF > ~/.config/gamemode/gamemode.ini
[general]
desiredgov=performance
igpu_desiredgov=powersave
softrealtime=auto
renice=15
ioprio=0

[custom]
# Automatyczne czyszczenie RAM i start turbo
start=sudo sysctl -w vm.drop_caches=3 && echo "LIGHTNING: ON" > /tmp/lightning_status && sudo cpupower frequency-set --governor performance
end=echo "LIGHTNING: OFF" > /tmp/lightning_status && sudo cpupower frequency-set --governor powersave
EOF
sudo systemctl enable ananicy-cpp 2>/dev/null || true

# 10. LIGHTNING RUN WRAPPER (wymusza gamemoderun dla każdego .exe)
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

# Wymuś GameMode dla WINE! Zmienia governory i priorytety automatycznie.
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

# 11. MODUŁ KOSMETYCZNY (Odpalany poprawnie, jako użytkownik!)
if [ -f "./Apply-Cosmetics.sh" ]; then
    chmod +x ./Apply-Cosmetics.sh
    ./Apply-Cosmetics.sh
fi

# 12. INSTALACJA FIXA KLAWIATURY CORSAIR
if [ -f "./corsair-debounce.py" ]; then
    echo "Instalacja blokady Key Chatter dla Corsair..."
    sudo cp ./corsair-debounce.py /usr/local/bin/corsair-debounce.py
    sudo cp ./corsair-debounce.service /etc/systemd/system/corsair-debounce.service
    sudo systemctl daemon-reload
    sudo systemctl enable --now corsair-debounce.service
fi

mkdir -p ~/.config/MangoHud
cp -f ./MangoHUD.conf ~/.config/MangoHud/MangoHud.conf 2>/dev/null || true

echo "========================================="
echo " LIGHTNING-OS V3.7.0 GOTOWY!"
echo "========================================="

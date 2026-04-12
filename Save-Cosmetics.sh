#!/bin/bash

echo "========================================="
echo " ZAPISYWANIE KONFIGURACJI LIGHTNING-OS"
echo "========================================="

# Ścieżka do Twojego folderu z kosmetyką
BASE_DIR="$PWD/cosmetic/dotfiles"
mkdir -p "$BASE_DIR/config"
mkdir -p "$BASE_DIR/local_share"

echo "1/2 Kopiowanie plików konfiguracyjnych (~/.config)..."
# Lista folderów i plików do backupu
configs=("kdeglobals" "kwinrc" "gtk-3.0" "gtk-4.0" "alacritty" "fastfetch")

for item in "${configs[@]}"; do
    if [ -e "$HOME/.config/$item" ]; then
        cp -rf "$HOME/.config/$item" "$BASE_DIR/config/"
        echo "  [ OK ] $item"
    fi
done

echo "2/2 Kopiowanie zasobów wizualnych (~/.local/share)..."
# Lista folderów z motywami, ikonami i czcionkami (w tym Konway i Pixelitos)
shares=("icons" "fonts" "aurorae" "color-schemes" "kwin" "plasma")

for item in "${shares[@]}"; do
    if [ -d "$HOME/.local/share/$item" ]; then
        cp -rf "$HOME/.local/share/$item" "$BASE_DIR/local_share/"
        echo "  [ OK ] $item"
    fi
done

# Zabezpieczenie Twojej ikony menu start
cp "$HOME/.local/share/icons/lightning-launcher.png" "$BASE_DIR/local_share/icons/" 2>/dev/null

echo "========================================="
echo " ZAPIS ZAKOŃCZONY POMYŚLNIE!"
echo " Folder 'dotfiles' jest gotowy do przeniesienia."
echo "========================================="
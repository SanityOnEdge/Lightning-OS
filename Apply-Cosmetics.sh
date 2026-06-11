#!/bin/bash

echo "========================================="
echo "  WGRYWANIE KOSMETYKI LIGHTNING-OS"
echo "========================================="

DOTFILES_DIR="$PWD/cosmetic/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "BŁĄD: Nie znaleziono folderu dotfiles!"
    exit 1
fi

echo "1/3 Przywracanie zasobów fizycznych (Ikony, Motywy, Fonty)..."
mkdir -p ~/.local/share
cp -rf "$DOTFILES_DIR/local_share/"* ~/.local/share/

# FIX IKONY: Jeśli w folderze ikon jest thunder.png, zrób z niego lightning-launcher.png
if [ -f "$HOME/.local/share/icons/thunder.png" ]; then
    cp -f "$HOME/.local/share/icons/thunder.png" "$HOME/.local/share/icons/lightning-launcher.png"
fi

fc-cache -f

echo "2/3 Przywracanie konfiguracji (KDE, Alacritty, Fastfetch)..."
mkdir -p ~/.config
cp -rf "$DOTFILES_DIR/config/"* ~/.config/

# --- POPRAWKA: USUNIĘTO SED ZMNIEJSZAJĄCY ODSTĘPY LITER ---
# Alacritty będzie teraz używać Twoich oryginalnych ustawień z pliku toml.

echo "3/3 Odświeżanie środowiska graficznego..."
dbus-send --print-reply --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1
systemctl --user restart plasma-plasmashell

echo "========================================="
echo " KOSMETYKA ZAAPLIKOWANA!"
echo "========================================="

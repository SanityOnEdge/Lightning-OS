#!/bin/bash

echo "========================================="
echo "  WGRYWANIE KOSMETYKI LIGHTNING-OS"
echo "========================================="

# Skrypt uruchamiany lokalnie przez użytkownika (bez sudo!)
DOTFILES_DIR="$PWD/cosmetic/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "BŁĄD: Nie znaleziono folderu dotfiles!"
    exit 1
fi

echo "1/3 Przywracanie zasobów fizycznych (Ikony, Motywy, Fonty)..."
mkdir -p ~/.local/share
cp -rf "$DOTFILES_DIR/local_share/"* ~/.local/share/

if [ -f "$HOME/.local/share/icons/thunder.png" ]; then
    cp -f "$HOME/.local/share/icons/thunder.png" "$HOME/.local/share/icons/lightning-launcher.png"
fi

fc-cache -f

echo "2/3 Przywracanie konfiguracji (KDE, Alacritty, Fastfetch)..."
mkdir -p ~/.config
cp -rf "$DOTFILES_DIR/config/"* ~/.config/

echo "3/3 Odświeżanie środowiska graficznego..."
# To polecenie wymaga środowiska użytkownika - stąd zakaz używania sudo
dbus-send --print-reply --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1
systemctl --user restart plasma-plasmashell

echo "========================================="
echo " KOSMETYKA ZAAPLIKOWANA!"
echo "========================================="

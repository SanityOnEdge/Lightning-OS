#!/bin/bash

echo "========================================="
echo "  WGRYWANIE KOSMETYKI LIGHTNING-OS"
echo "========================================="

DOTFILES_DIR="$PWD/cosmetic/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "BŁĄD: Nie znaleziono folderu dotfiles. Uruchom najpierw Save-Cosmetics.sh!"
    exit 1
fi

echo "1/3 Przywracanie zasobów fizycznych (Ikony, Motywy, Fonty)..."
mkdir -p ~/.local/share
cp -rf "$DOTFILES_DIR/local_share/"* ~/.local/share/
fc-cache -f

echo "2/3 Przywracanie konfiguracji (KDE, GTK, Alacritty, Fastfetch)..."
mkdir -p ~/.config
cp -rf "$DOTFILES_DIR/config/"* ~/.config/

# Naprawa czcionki w Alacritty (jeśli po wgraniu nadal są przerwy, skrypt to koryguje)
# Offset ustaliliśmy na -4 dla PxPlus ToshibaTxL1 8x16 przy rozmiarze 16.0
if [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
    sed -i 's/x = .*/x = -4/' "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null
fi

echo "3/3 Odświeżanie środowiska graficznego..."
# Restart KWin (Menedżer okien)
dbus-send --print-reply --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1

# Restart Plasmashell (Pasek zadań i menu)
systemctl --user restart plasma-plasmashell

echo "========================================="
echo " KOSMETYKA ZAALIKOWANA!"
echo " System Lightning-OS jest gotowy do pracy."
echo "========================================="

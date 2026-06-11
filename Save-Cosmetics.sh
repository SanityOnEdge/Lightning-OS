#!/bin/bash

# =================================================================
# LIGHTNING-OS SAVE-COSMETICS V3.7.0 - FULL BACKUP MODE
# =================================================================

echo "========================================="
echo " ZAPISYWANIE KOMPLETNEJ WIZUALIZACJI"
echo "========================================="

# Ścieżka do Twojego folderu z kosmetyką
BASE_DIR="$PWD/cosmetic/dotfiles"
mkdir -p "$BASE_DIR/config"
mkdir -p "$BASE_DIR/local_share"

echo "1/2 Zgrywanie konfiguracji ustawień (~/.config)..."
# Rozszerzona lista plików (tapety, kolory, splash screeny, layouty ekranów)
configs=(
    "autostart"
    "alacritty"
    "btop"
    "btop-launcher.sh" # <--- DODANE: Twój fizyczny skrypt uruchamiający
    "autostart"        # <--- DODANE: Folder ze skrótami (KDE czyta go przy starcie)
    "fastfetch"
    "fish"
    "kdeglobals"
    "kwinrc"
    "gtk-3.0"
    "gtk-4.0"
    "ksplashrc"
    "kscreenlockerrc"
    "kcminputrc"
    "plasmarc"
    "plasma-org.kde.plasma.desktop-appletsrc"
    "plasmashellrc"
    "kwinrulesrc"
)

for item in "${configs[@]}"; do
    if [ -e "$HOME/.config/$item" ]; then
        cp -rf "$HOME/.config/$item" "$BASE_DIR/config/"
        echo "  [ OK ] Konfiguracja: $item"
    fi
done

echo "2/2 Zgrywanie plików motywów i tapet (~/.local/share)..."
# Dodano folder 'wallpapers' oraz 'plasma/look-and-feel' dla Splash Screenów
shares=(
    "icons"          # Ikony (Pixelitos itp.)
    "fonts"          # Czcionki
    "aurorae"        # Obramowania okien
    "color-schemes"  # Schematy kolorów (Konway itp.)
    "kwin"           # Skrypty KWin
    "plasma"         # Motywy pulpitu i Splash Screeny
    "wallpapers"     # TWOJE TAPETY (teraz ich nie stracisz)
)

for item in "${shares[@]}"; do
    if [ -d "$HOME/.local/share/$item" ]; then
        cp -rf "$HOME/.local/share/$item" "$BASE_DIR/local_share/"
        echo "  [ OK ] Zasoby: $item"
    fi
done

echo "========================================="
echo " ZAPIS ZAKOŃCZONY!"
echo " Teraz Twoje tapety, kolory i splash"
echo " screeny są bezpieczne w folderze cosmetic."
echo "========================================="

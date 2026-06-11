# Lightning-OS

Zestaw skryptów w Bashu i plików konfiguracyjnych do optymalizacji Linuxa. Cel to maksymalna wydajność w grach i automatyzacja ustawień kosmetycznych. 

Projekt powstał dla dystrybucji CachyOS pod moją konfigurację sprzętową (AMD, Radeon RX 7600). Można go łatwo zmodyfikować pod inne podzespoły.

## Co to potrafi

* **Zarządzanie wydajnością:** Automatyczna zmiana trybu pracy procesora (performance/powersave). Optymalizacja pamięci (swappiness, max_map_count).
* **Środowisko gier:** Autorski wrapper uruchomieniowy. Można go użyć jako parametru w Steam (`lightning-run %command%`). W locie konfiguruje zmienne dla DXVK i zarządza procesami w tle. 
* **"Windows like expierence":** Integracja z menu kontekstowym. Pozwala odpalać instalatory `.exe` przez Wine bezpośrednio z prawego przycisku myszy. Działa z większością gier.
* **Automatyzacja systemu:** Szybka instalacja zależności. Automatyczna konfiguracja uprawnień, pliku fstab oraz struktury w `/opt/`.
* **Kopia zapasowa wyglądu:** Szybki zapis i przywracanie pełnej konfiguracji wizualnej (dotfiles, KDE Plasma, Alacritty).

## Główne pliki

* `Setup-Lightning.sh` - instalator i konfigurator systemu.
* `Lightning-Core.sh` - skrypt sterujący zasilaniem i wydajnością.
* `Apply-Cosmetics.sh` / `Save-Cosmetics.sh` - narzędzia do synchronizacji wyglądu.
* `MangoHUD.conf` / `DXVk.conf` - moje własne presety ustawień.

## Narzędzia i technologie

Bash, Linux (Arch/CachyOS), KDE Plasma, Wine/Proton, DXVK.

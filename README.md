# Lightning-OS

Zestaw skryptów w Bashu i plików konfiguracyjnych do optymalizacji Linuxa. Cel to maksymalna wydajność w grach i automatyzacja ustawień kosmetycznych. 

Projekt powstał dla dystrybucji CachyOS pod moją konfigurację sprzętową (AMD, Radeon RX 7600). Można go łatwo zmodyfikować pod inne podzespoły.

## O procesie tworzenia (AI-Assisted Development)

Architektura systemu, logika projektu oraz struktura przepływu danych zostały zaprojektowane autorsko. Sam kod źródłowy został wygenerowany, debugowany i zoptymalizowany przy wykorzystaniu technik Prompt Engineeringu oraz modeli LLM. Projekt stanowi praktyczny przykład nowoczesnego podejścia AI-Assisted Development, gdzie sztuczna inteligencja pełni rolę wykonawczą dla zdefiniowanych założeń inżynieryjnych.

## Co to potrafi

* **Zarządzanie wydajnością:** Automatyczna zmiana trybu pracy procesora (performance/powersave). Optymalizacja pamięci (swappiness, max_map_count).
* **Środowisko gier:** Autorski wrapper uruchomieniowy. Można go użyć jako parametru w Steam (`lightning-run %command%`). W locie konfiguruje zmienne dla DXVK i zarządza procesami w tle. 
* **"Windows like expierence":** Integracja z menu kontekstowym. Pozwala odpalać instalatory `.exe` przez Wine bezpośrednio z prawego przycisku myszy. Działa z większością gier.
* **Automatyzacja systemu:** Szybka instalacja zależności. Automatyczna konfiguracja uprawnień, pliku fstab oraz struktury w `/opt/`.
* **Kopia zapasowa wyglądu:** Szybki zapis i przywracanie pełnej konfiguracji wizualnej (dotfiles, KDE Plasma, Alacritty).
* 
## Integracja z Lossless Scaling (LSFG)

System posiada wbudowaną obsługę generowania klatek przez Lossless Scaling wewnątrz wrappera `lightning-run`. Ze względów licencyjnych pliki `.dll` nie są dołączone do projektu.

**Jak z tego skorzystać:**
Wystarczy, że przed uruchomieniem instalatora `Setup-Lightning.sh` wrzucisz swoje pliki `Lossless.dll` oraz `DDraw.dll` do głównego folderu pobranego repozytorium. Skrypt instalacyjny sam skopiuje je do struktury systemowej (`/opt/`), a wrapper automatycznie zintegruje je z grami.

## Główne pliki

* `Setup-Lightning.sh` - instalator i konfigurator systemu.
* `Lightning-Core.sh` - skrypt sterujący zasilaniem i wydajnością.
* `Apply-Cosmetics.sh` / `Save-Cosmetics.sh` - narzędzia do synchronizacji wyglądu.
* `MangoHUD.conf` / `DXVk.conf` - moje własne presety ustawień.

## Narzędzia i technologie

Bash, Linux (Arch/CachyOS), KDE Plasma, Wine/Proton, DXVK.

# Lightning-OS

A collection of Bash scripts and configuration files for optimizing Linux. The goal is to achieve maximum gaming performance and automate cosmetic settings.

The project was created for the CachyOS distribution tailored to my hardware configuration (AMD, Radeon RX 7600). It can be easily modified for other components.

## About the Development Process (AI-Assisted Development)

The system architecture, project logic, and data flow structure were designed in-house. The source code itself was generated, debugged, and optimized using Prompt Engineering techniques and LLM models. The project serves as a practical example of a modern AI-Assisted Development approach, where artificial intelligence acts as an executor for defined engineering objectives.

## What It Can Do

* **Performance Management:** Automatic switching of the CPU operating mode (performance/powersave). Memory optimization (swappiness, max_map_count).
* **Gaming environment:** A custom launch wrapper. It can be used as a parameter in Steam (`lightning-run %command%`). It configures DXVK variables on the fly and manages background processes.
* **“Windows-like experience”:** Integration with the context menu. Allows you to launch `.exe` installers via Wine directly from the right-click menu. Works with most games.
* **System automation:** Quick installation of dependencies. Automatic configuration of permissions, the fstab file, and the directory structure in `/opt/`.
* **Appearance backup:** Quick saving and restoration


## Integration with Lossless Scaling (LSFG)

The system includes built-in support for frame generation via Lossless Scaling within the `lightning-run` wrapper. Due to licensing restrictions, the `.dll` files are not included in the project.

**How to use it:**
Simply place your `Lossless.dll` and `DDraw.dll` files in the root folder of the downloaded repository before running the `Setup-Lightning.sh` installer. The installation script will copy them to the system directory (`/opt/`), and the wrapper will automatically integrate them with the games.

## Main Files

* `Setup-Lightning.sh` – system installer and configurator.
* `Lightning-Core.sh` – script controlling power and performance.
* `Apply-Cosmetics.sh` / `Save-Cosmetics.sh` – tools for synchronizing the appearance.
* `MangoHUD.conf` / `DXVk.conf` – my own preset configurations.

## Tools and Technologies

Bash, Linux (Arch/CachyOS), KDE Plasma, Wine/Proton, DXVK.

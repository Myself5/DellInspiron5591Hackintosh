# Dell Inspiron 5767 Hackintosh (OpenCore)
macOS on Dell Inspiron 5767 (i7-7500u)

![OpenCore Version](https://img.shields.io/badge/opencore-v0.6.2-blue)

![Screenshot 1](../master/Pictures/neofetch.png?raw=true)

## Disclaimer
***Always make a backup before start*.
I'm not responsible for bricked laptops, dead USB drives, thermonuclear war, or you getting fired because the Intel processor exploded (here I'm kidding you :stuck_out_tongue_winking_eye:).**

![OpenCore logo](https://github.com/acidanthera/OpenCorePkg/blob/master/Docs/Logos/OpenCore_with_text_Small.png)

## Guide

### Requirements
1. Running on macOS or Windows (on Windows you can use WSL https://docs.microsoft.com/it-it/windows/wsl/install-win10)
2. [MaciASL](https://github.com/acidanthera/MaciASL/releases) for macOS; [acpidump](https://www.acpica.org/downloads) for Windows
3. Curl installed (if not just run the script and complete the installation process)
4. gibMacOS available here https://github.com/corpnewt/gibMacOS (in addition for Windows is required [BDU](http://cvad-mac.narod.ru/index/bootdiskutility_exe/0-5), [Paragon Partition Manager](https://www.paragon-software.com/free/pm-express/) and [HFS+ for Windows](https://www.paragon-software.com/it/home/hfs-windows/))
5. USB 2.0 flash drive 12 GB or more (if you have **USB 3.0 plug in into USB 2.0** port during booting phase)
6. Internet connection (obviously :stuck_out_tongue_winking_eye:)

### BIOS setup
1. Make sure your BIOS is up to date. If not install latest from Dell site
2. Reboot to BIOS Setup
3. Enable Boot from USB and Legacy boot
4. Disable Fast boot and Secure boot
5. Disable Intel VT-d
6. Make sure SATA mode is set to AHCI

### Bootable USB creation
1. Run *gibMacOS.bat* or *gibMacOS.command* (Windows/macOS respectively)
2. Choose latest macOS version (10.15.5) and wait for download to finish
3. **On Windows**
    1. Navigate to *gibMacOS/macOS Downloads/publicrelease/something_macOS Catalina*
    2. Rename *InstallESDDmg.pkg* to *InstallESD.dmg*
    3. Open *InstallInfo.plist* and search for
            
            <string>InstallESDDmg.pkg</string>
            
        change to
        
            <string>InstallESD.dmg</string>
            
        Remove
        
            <key>chunklistURL</key>
            <string>InstallESDDmg.chunklist</string>
            <key>chunklistid</key>
            <string>com.apple.chunklist.InstallESDDmg</string>
            
        Search for
        
            <string>com.apple.pkg.InstallESDDmg</string>
            
        change to
        
            <string>com.apple.dmg.InstallESD</string>
            
        4. Create a new folder named *SharedSupport* and put in it following files
            - *BaseSystem.dmg*
            - *BaseSystem.chunklist*
            - *InstallInfo.plist*
            - *InstallESD.dmg*
            - *AppleDiagnostics.dmg*
            - *AppleDiagnostics.chunklist*
            
        5. Open BDU
            1. Click on *"Format disk"* and tick *"Not install"* under *"Clover Bootloader Source"* section since we want to use OpenCore instead.
            2. Under *"Multi partitioning"* section tick *"Boot Partition Size (MB)"* and set it to 200.
            3. Press *"OK"* to start the process.
            
            5. Navigate to *"Tools">"Extract HFS (HFS+) partition from DMG-files"* and choose *BaseSystem.dmg* file under *gibMacOS/macOS Downloads/publicrelease/something_macOS Catalina*
            6. Once completed expand (if not expanded) your USB drive under *"Destination Disk"* section and select *"Part2: something"*
            7. Click on *"Restore Partition"* and choose *"4.hfs"* file you've extracted previously
        6. Open Paragon Partition Manager and extend HFS partition to fit USB remaining free space
        7. Open HFS+ for Windows and mount HFS partition
        8. Open it with Windows Explorer and copy *SharedSupport* folder to *Install macOS Catalina.app/Contents*. Wait for process to finish (it may takes up to 15 minutes)
        9. Now you have your bootable USB ready to start [EFI Installation](#EFI-Installation)
    **On macOS**
    1. Open Disk Utility and navigate to *"View">"Show all devices"*
    2. Select your USB drive and click on *"Initialise"*
    3. Choose a name and select *"Mac OS extended (journaled)"* from *"Format"* dropdown menu and *"Master Boot Record (MBR)"* from *"Scheme"* dropdown menu
    4. Click on *"Initialise"* and wait for process to complete
    5. Run *BuildmacOSInstallApp.command* under *gibMacOS-master* folder
    6. Once done open Terminal and type the following
            
            sudo "/path/to/Install macOS Catalina.app/Contents/Resources/createinstallmedia" --volume  /Volumes/your_usb --nointeraction
            
    7. Now you have your bootable USB ready to start [EFI Installation](#EFI-Installation)
    
### EFI Installation
1. Clone this repository
2. Run build.sh from terminal (if using WSL on Windows first install *dos2unix* and run *dos2unix build.sh* to convert the script to unix format)

3. Open *Out/EFI/OC/Kexts/itlwm.kext/Contents/Info.plist* and edit Wi-Fi connections' info under *"IOKitPersonalities">"WiFiConfig"* setting your Wi-Fi's SSID and password

4. Open *Out/EFI/OC/config.plist* and follow [this guide](https://dortania.github.io/OpenCore-Desktop-Guide/post-install/iservices) to correctly fill *"PlatformInfo">"Generic"* empty fields (**Do not change *"SystemProductName"* value, just use the given one**)

5. Then copy entire *EFI* folder to your USB flash drive EFI partition you created previously. It should look like the following

![Screenshot 2](../master/Pictures/OC_screen.png?raw=true)

6. Now it's time to boot macOS installer from your USB drive

### macOS installation
1. On OpenCore boot screen select *"Install macOS from your_usb"*

2. Assuming your are dual booting with Windows once you have reached install screen choose *"macOS Reinstallation"*

3. Select target partition created before and follow the installer

### Post installation
1. Download [MountEFI](https://github.com/corpnewt/MountEFI) script and run it

2. Select HDD macOS partition to mount EFI

3. Open your USB drive and head to EFI folder

4. Copy *BOOT* and *OC* folders to HDD EFI partition (if you've previously installed CLOVER first make a backup, then delete *CLOVER* folder and *BOOT/BOOTx64.efi* or just replace it with OC's one)

5. Follow this link's guide to disable "CFG Lock" https://dortania.github.io/OpenCore-Desktop-Guide/extras/msr-lock.html
    (Remeber to disable *"AppleCpuPmCfgLock"* and *"AppleXcpmCfgLock"* under *"Kernel">"Quirks"* once done)
    
6. Open System Preferences and disable PowerNap and wake on ethernet under *"Energy Saving"*

7. Run script *Audio/ComboJack_Installer/install.sh* to fix 3.5mm jack output and reboot. When you will connect a dialog asking you to select what you connected should show up

8. Copy *Audio/ComboJack_installer/VerbStub.kext* to your HDD *EFI/OC/Kexts* folder

## Table of contents
### ACPI

| ACPI file | Description |
| --- | --- |
| SSDT-DDGP.dsl | Disables AMD Radeon M445 |
| SSDT-DMAC.dsl | Adds missing DMAC device |
| SSDT-EC-USBX.dsl | Adds missing EC controller and inject USB power properties |
| SSDT-EXT4.dsl | Wakes our screen up on waking |
| SSDT-GPI0.dsl | Injects GPI0 to enable interrupt mode for I2C trackpad |
| SSDT-MCHC.dsl | Adds missing MCHC device |
| SSDT-MEM2.dsl | Adds missing MEM2 device |
| SSDT-PLUG.dsl | Injects plugin-type to fix Native Power Management |
| SSDT-PMCR.dsl | Adds missing PMCR device |
| SSDT-PNLF.dsl | Injects backlight properties to fix backlight control |
| SSDT-SBUS.dsl | Fixes Serial BUS for correct sensors management |

### Kexts

| Kext file | Description |
| --- | --- |
| AppleALC | Fixes onboard audio |
| CPUFriend | Fixes CPU power management |
| Lilu | Fixes lot of things and make laptop boot |
| VirtualSMC | Fakes our laptop as MacBook making it boot |
| VoodooPS2Controller | Fixes keyboard |
| WhateverGreen | Fixes Intel HD Graphics |
| VoodooI2C | Fixes trackpad |
| VoodooI2CHID | VoodooI2C plugin for Precision Trackpad |
| HibernationFixup | Fixes hibernation process |

## Troubleshooting
To get help just open a issue or best thing head over my thread
- https://www.tonymacx86.com/threads/guide-opencore-dell-inspiron-17-5767-i7-7500u.299242
or visit hackintosh sites on the web
- https://www.tonymacx86.com
- https://www.insanelymac.com
and others

## Where can I learn more?
- https://dortania.github.io
- https://www.tonymacx86.com
- https://www.insanelymac.com

## Thanks
- @Acidanthera team for this new and more macOS friendly bootloader
- @_bplank for the updated guide for Big Sur
- @dortania team for detailed guides
- @CorpNewt for his amazing scripts, ACPIs, plugins
- @VoodooI2C for make I2C trackpad's gestures possible
- @RehabMan for his crucial role in the hackintosh world. That will never be forgotten since most of the projects above are based on his work.
- @zxystd for his work on Intel Wi-Fi cards (no anyone else wanted to work on this in the past so he's doing something deemed by all impossible)

# Genesis-Plus-GX [Builds]  
![MainMenu.png](https://bitbucket.org/repo/7AjE6M/images/3565283297-MainMenu.png)  

## Pre-Compiled Community [Builds]:  
**P4PR1UM:** *NO EXRomSize Support for SegaChannel (ONLY P4PR1UM Compatibility)*  
**EXOnly:** *EXRomSize Support for SegaChannel ONLY (NO P4PR1UM Compatibility)*  
**Both:** *EXRomSize Support for SegaChannel + P4PR1UM Compatibility*  

# INSTALLATION METHODS  
*Building from [Source] using the RetroPie-Setup Module Script is Recommended if applicable*  

## [Source] Install from RetroPie-Setup:  
Get the [lr-genesis-plus-gx-EX.sh] Script and place in [/home/$USER/RetroPie-Setup/scriptmodules/libretrocores]  
```bash
wget https://raw.githubusercontent.com/RapidEdwin08/Genesis-Plus-GX-Expanded-Rom-Size/master/builds/lr-genesis-plus-gx-EX.sh -P ~/RetroPie-Setup/scriptmodules/libretrocores/

```
Open RetroPie-Setup from Emulationstation or CLI  
```bash
cd ~/RetroPie-Setup && sudo ./retropie_setup.sh; cd ~

```
From RetroPie Setup -> Manage Packages -> Manage *Experimental* Packages  
Locate **[lr-genesis-plus-gx-EX]** in the List -> Update/Install from Source  
**Results:** Additional Core ***[lr-genesis-plus-gx-EX]*** with Support for ***Both*** SegaChannel+P4PR1UM  

## [Build] Install Manually from RetroArch:  
Copy *[genesis_plus_gx_libretro.dll]* or *[genesis_plus_gx_libretro.so]* to your Device  
Open Retroarch -> Settings -> Cores -> Manage Cores -> ***Install or Restore a Core***  
Navigate to the *[genesis_plus_gx_libretro.dll]* or *[genesis_plus_gx_libretro.so]* you Copied to your Device  

## [Build] Install Manually for RetroPie:  
Copy the Entire ***[lr-genesis-plus-gx-EX]*** Folder to [/opt/retropie/libretrocores] on your Device:  
```bash
sudo cp -R ./lr-genesis-plus-gx-EX /opt/retropie/libretrocores

```
Set the Core File Permissions for Executable  
```bash
sudo chmod 755 /opt/retropie/libretrocores/lr-genesis-plus-gx-EX/genesis_plus_gx_libretro.so

```
Edit the *megadrive* Emulator Config file  
```bash
nano /opt/retropie/configs/megadrive/emulators.cfg

```
Add the Line for the additional Emulator ***[lr-genesis-plus-gx-EX]*** to emulators.cfg  
```bash
lr-genesis-plus-gx-EX = "/opt/retropie/emulators/retroarch/bin/retroarch -L /opt/retropie/libretrocores/lr-genesis-plus-gx-EX/genesis_plus_gx_libretro.so --config /opt/retropie/configs/megadrive/retroarch.cfg %ROM%"
```
*0ptional* Add the additional *ex-swap.sh* Emulator Script  
```bash
cd ~
wget https://raw.githubusercontent.com/RapidEdwin08/Genesis-Plus-GX-Expanded-Rom-Size/master/builds/ex-swap.sh -P ~/
sudo mv ~/ex-swap.sh /opt/retropie/libretrocores/lr-genesis-plus-gx-EX
sudo chmod 755 /opt/retropie/libretrocores/lr-genesis-plus-gx-EX/ex-swap.sh
```
*0ptional* Add the Line for the additional *ex-swap.sh* Emulator ***[lr-genesis-plus-gx-EX-SWAP]*** to emulators.cfg  
```bash
lr-genesis-plus-gx-EX-SWAP = "/opt/retropie/libretrocores/lr-genesis-plus-gx-EX/ex-swap.sh %ROM%"
```

## [Source] Generic Device Build:  
*Clean out any 0ld Source Folder prior if applicable*  
```bash
cd ~
rm -Rf ~/Genesis-Plus-GX-Expanded-Rom-Size

```
Get the [Genesis-Plus-GX-Expanded-Rom-Size] *Source* on your Device  
```bash
cd ~
git clone --depth=1 https://github.com/BillyTimeGames/Genesis-Plus-GX-Expanded-Rom-Size.git
# Stream Edit Makefile to ensure MAX_ROM_SIZE
sed -i 's+MAX_ROM_SIZE.*+MAX_ROM_SIZE = 93554432+g' ~/Genesis-Plus-GX-Expanded-Rom-Size/Makefile.libretro

```
Should you encounter make 4.4.1 error: 'else' without a previous 'if' on your Device  
```bash
# Stream Edit workaround make 4.4.1 error: 'else' without a previous 'if' 520:7
sed '520s+else+//else+' ~/Genesis-Plus-GX-Expanded-Rom-Size/libretro/libretro-common/cdrom/cdrom.c > /tmp/make.441
mv /tmp/make.441 ~/Genesis-Plus-GX-Expanded-Rom-Size/libretro/libretro-common/cdrom/cdrom.c

```
Navigate to the *Source* folder Downloaded and *make*  
The Makefile should Auto-Detect *Device* and Build appropriate *Core*  
Successful Build should ouptut **[genesis_plus_gx_libretro.so]**  
```bash
cd ~/Genesis-Plus-GX-Expanded-Rom-Size
make -f Makefile.libretro clean
make -f Makefile.libretro

```
## [Source] Specific Platform Build:  
GIT <> CODE Dowload ZIP and Extract *[Genesis-Plus-GX-Expanded-Rom-Size-master]* *Source* Folder on *Device*  
Specify the [platform= ] +parameters for *Device* and Build appropriate *Core*  
Successful Build should ouptut **[genesis_plus_gx_libretro.dll]** in this Example  
```bash
cd /d C:\temp\Genesis-Plus-GX-Expanded-Rom-Size-master
make -f Makefile.libretro platform=win CC=x86_64-w64-mingw-gcc CXX=x86_64_w64-mingw-g++ clean
make -f Makefile.libretro platform=win CC=x86_64-w64-mingw-gcc CXX=x86_64_w64-mingw-g++

```

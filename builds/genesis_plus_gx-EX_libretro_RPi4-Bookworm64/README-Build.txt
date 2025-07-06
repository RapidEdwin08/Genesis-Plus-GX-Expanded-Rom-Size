Binary Build Installation (Manual Install):
---------------------------------------------------
Place Entire folder "lr-genesis-plus-gx-EX" to the following directory on your Device
"/opt/retropie/libretrocores"

chmod 755 /opt/retropie/libretrocores/genesis_plus_gx_libretro.so

Add Line for lr-genesis-plus-gx-EX to the following file on your Device
"/opt/retropie/configs/megadrive/emulators.cfg"

lr-genesis-plus-gx-EX = "/opt/retropie/emulators/retroarch/bin/retroarch -L /opt/retropie/libretrocores/lr-genesis-plus-gx-EX/genesis_plus_gx_libretro.so --config /opt/retropie/configs/megadrive/retroarch.cfg %ROM%"


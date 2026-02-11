# ExpressLRS Lua Scripts

Lua configuration scripts for ExpressLRS on EdgeTX and OpenTX radios. Two variants are available depending on your radio's screen type: a **black & white** version for legacy LCD radios, and a **color LCD** version with a modern LVGL interface and widgets.

## Black & White Screen Radios

Use **`blackwhite/elrs.lua`** for radios with a black & white LCD screen (e.g. RadioMaster Zorro, Boxer, TX12, Jumper T-Lite, etc.).

- Works with both **OpenTX** and **EdgeTX** (all versions)
- Compatible with **ExpressLRS v2.0 through current** -- there is no need for version-specific scripts, just use `elrs.lua`

### Installation

1. Copy `blackwhite/elrs.lua` to `SCRIPTS/TOOLS/` on your radio's SD card.
2. Delete any old versions such as `ELRS.lua`, `elrsV2.lua`, or `elrsV3.lua`. These version-labeled filenames have been obsoleted.

### Downloading from GitHub

Click the `elrs.lua` file link, find the **Raw** button near the top of that page. Right-click, **Save link as...**, and copy the `.lua` file into the `/SCRIPTS/TOOLS` directory of your radio's SD card.

## Color LCD Radios

Use the scripts in the **`color/`** directory for radios with a color touchscreen LCD (e.g. RadioMaster TX16S, Jumper T18, FlyDragon, etc.).

- Requires **EdgeTX 2.11.5, 2.12-rc4, 3.0 or newer** (uses the LVGL graphics framework)
- Compatible with **ExpressLRS v2.0 through current**

The color LCD package includes three components: the **ExpressLRS Configuration Tool**, the **ELRS Telemetry Widget**, and the **VTX Administrator Widget**.

### ExpressLRS Configuration Tool

The main configuration tool (`SCRIPTS/TOOLS/expresslrs.lua`) lets you configure your ExpressLRS transmitter and receiver settings directly from your radio: packet rate, telemetry ratio, switch mode, model match, antenna mode, TX power, WiFi connectivity, and more.

![ExpressLRS Configuration Tool](screenshots/tool_main.png)

### ELRS Telemetry Widget

The telemetry widget (`WIDGETS/ELRSTelemetry/`) displays real-time link statistics on your home screen: link quality, RSSI, range, RF mode, TX power, battery voltage, current, GPS, and flight mode. It supports multiple screen resolutions (800x480, 480x320, 480x272, 320x480, 320x240).

![Widgets on home screen](screenshots/widgets.png)

![Telemetry widget full screen](screenshots/widget_telemetry_fullscren.png)

### VTX Administrator Widget

The VTX Administrator widget (`WIDGETS/ELRSVTXAdmin/`) provides control over your video transmitter settings -- band, channel, power level, and pit mode -- directly from your radio telemetry screen. It also supports 6POS quick change for rapid VTX channel switching via a 6POS switch.

![VTX Administrator widget full screen](screenshots/widget_vtxadmin_fullscreen.png)

### Installation

Copy the contents of the `color/` directory to the **root** of your radio's SD card, preserving the directory structure. When done, your SD card should contain:

```
SCRIPTS/
  ELRSLib/
    crsf.lua
  TOOLS/
    expresslrs.lua
WIDGETS/
  ELRSTelemetry/
    main.lua
    loadable.lua
    ui/
      ...
  ELRSVTXAdmin/
    main.lua
    loadable.lua
    ui/
      ...
```

The shared library `SCRIPTS/ELRSLib/crsf.lua` is required by the tool and both widgets.

## Compatibility

| Variant | Firmware | ExpressLRS |
|---------|----------|------------|
| Black & White (`blackwhite/`) | OpenTX or EdgeTX (any version) | v2.0+ |
| Color LCD (`color/`) | EdgeTX 2.11.5+, 2.12-rc4+, or 3.0+ | v2.0+ |

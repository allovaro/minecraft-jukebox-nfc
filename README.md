# Minecraft Jukebox — an NFC music box for kids 🎵

**English** · [Русский](README.ru.md)

![Jukebox](cad/preview.png)

A 3D-printed Minecraft jukebox that plays real music. Your kid drops a pixel-art "music disc" into the slot on top,
and the jukebox plays the song, fairy tale or playlist linked to that disc. While it plays, the slot glows in the disc's color.
Pull the disc out and playback pauses. Put the same disc back and it resumes where it left off.

It runs on ESPHome and Home Assistant. The music stays in your Home Assistant media folder, and each disc only carries an NFC tag.
You can make as many discs as you like.

```
 music disc with NFC tag
        │  (a few mm of plastic)
        ▼
   PN532 (I2C) ──► ESP32-S3 ──Wi-Fi──► Home Assistant
                       ▲                   │ "disc 04-A1-… = lullaby.mp3"
                       │ FLAC stream       │
                       └───────────────────┘
                   ESP32-S3 ──I2S──► MAX98357A ──► 2 speakers
                   ESP32-S3 ──────► 10 × WS2812 (glowing slot)
```

Home Assistant decides *what* to play. The jukebox is a regular media player (`media_player.music_cube_player`),
so you can also send it music, TTS announcements or radio from anywhere in Home Assistant.

## Features

- 🎮 Minecraft jukebox look: dark frame, checkerboard panels, pixel-art discs that stick out of the slot
- 💿 Insert a disc to play, remove it to pause, insert the same disc again to resume
- 🌈 Each disc has its own color: the slot "breathes" in that color while the disc plays
- 🔊 Physical volume and play/pause buttons, hidden in the panel pattern; volume is capped at 70% for little ears
- ✍️ Write Home Assistant tags to discs from the HA UI (from [adonno/tagreader](https://github.com/adonno/tagreader))
- 📐 Fully parametric OpenSCAD model. The panels print face-down, so they pick up the texture of the build plate

## Repository layout

| Path | What it is |
|---|---|
| `esphome/music-cube.yaml` | ESPHome firmware: NFC (based on adonno/tagreader), audio, buttons, LEDs. Validated with `esphome config` (ESPHome 2026.10.1) |
| `homeassistant/music_cube_automation.yaml` | Automation: disc → music + LED color, removed → pause, same disc → resume |
| `cad/music_cube.scad` | Parametric OpenSCAD model; pick a part with the `part` variable |
| `cad/stl/*.stl` | Ready-to-print STLs, already oriented for printing |
| `cad/preview.png`, `cad/inside.png` | Renders: assembled view and internals |

Code comments are in Russian; this README covers everything you need.

## Bill of materials

| Part | Purpose |
|---|---|
| **ESP32-S3 DevKitC-1 N16R8** | Brain + Wi-Fi + audio. PSRAM is needed for the audio buffer |
| **MAX98357A** I2S amplifier (3 W) | Digital audio straight from the ESP32 |
| **PN532** NFC board (blue, 78.5×49 mm, 4 mounting holes) | Reads and writes NFC tags |
| **NTAG215** stickers, Ø25 mm | One per disc |
| 2 small speakers, 8 Ω (~Ø40 mm) | Front and back, wired in parallel |
| 10 × **WS2812** LEDs (individual boards) + 330 Ω resistor | Glowing slot |
| 3 × tactile buttons **6×6 mm, 8–9 mm tall** | Volume up / down, play/pause |
| USB cable + 5 V 2 A power supply | Power |
| M3×6 screws ×4, M3×10 countersunk ×4, rubber feet ×4 | PN532 mount, bottom plate |
| Filament: dark (frame, discs), terracotta/orange (panels), natural PETG or white PLA (slot), bright colors (disc labels) | |

**Why not an ESP8266 / D1 mini?** ESPHome's media player only runs on ESP32. ESP8266 boards cannot play audio in ESPHome.

**Already have an analog amp** (PAM8403 etc.)? Use a **PCM5102A** I2S DAC instead of the MAX98357A and feed its L/R output
into your amp. The firmware stays the same.

## Wiring

| From | To ESP32-S3 | Notes |
|---|---|---|
| PN532 VCC / GND | 3V3 / GND | |
| PN532 SDA / SCL | GPIO8 / GPIO9 | Set the board to **I2C mode** (switch or jumpers, labeled on the PCB) |
| MAX98357A VIN / GND | 5V / GND | Power from 5 V, not 3.3 V |
| MAX98357A LRC / BCLK / DIN | GPIO5 / GPIO6 / GPIO7 | |
| Speakers | MAX98357A + / − | Two 8 Ω speakers **in parallel** (= 4 Ω, fine for the MAX98357A) |
| Buttons vol+ / vol− / play | GPIO15 / GPIO16 / GPIO17 | Other button pin to GND |
| WS2812 DIN / 5V / GND | GPIO4 (via 330 Ω) / 5V / GND | Daisy-chain all 10: DOUT → next DIN |

Pins can be changed in the `substitutions` block at the top of the YAML.
Avoid GPIO0, 3, 45, 46 (strapping), 19/20 (USB) and 35–37 (PSRAM on N16R8).

## 3D printing

Open `cad/music_cube.scad` in OpenSCAD. **Measure your speakers and PN532 board first** and adjust
`spk_d`, `nfc_len`, `nfc_wid`, `nfc_ant` and `nfc_hole_in` in the Customizer. Then select a `part`, render (F6) and export STL.
Or just grab the STLs from `cad/stl/`.

| Part | Qty | Color | How to print |
|---|---|---|---|
| `body` — frame with roof | 1 | dark | Roof down (already flipped), no supports |
| `bottom` — bottom plate | 1 | dark | Flat. Electronics sit on it; held by 4 screws |
| `panel_side` — checkerboard panel | 4 | terracotta | **Face down** on a textured plate |
| `panel_top` — half of the top panel | 2 | terracotta | Face down |
| `slot_unit` — disc slot | 1 | **natural PETG or white PLA** | Rim down (already flipped). Glows from the LEDs |
| `disc` — music disc | as many as you like | dark + accent color | Flat, with two slicer stops (see below) |

**How it goes together**
- The **side panels** sit in 1.6 mm pockets on the frame. The **top panels** have a tongue on the back that fits a groove in the roof.
  All panels stand 2.8 mm proud of the frame (parameter `panel_out`). Glue them on last.
- Through the checkerboard holes you see the dark wall behind, just like the original block. Behind the speakers the wall is open, so sound comes out through the holes.
- The **slot unit** is installed **from inside**, while the bottom plate is off. Its rim pokes through the roof and glows; a ledge under the roof holds it, and you glue it along that ledge.
- The **PN532** mounts on 4 standoffs on the back of the slot unit. Its antenna sits about 4 mm off the disc center, which does not affect reading.
  Measure your board, especially `nfc_ant` (the distance from the edge without the header to the center of the antenna).
- The **LEDs** are glued onto the slot walls: 8 in a row on the front wall plus 1 on each end. The light-colored plastic diffuses the light.
- The **buttons and power cable** are hidden in the back panel pattern: the stem of each 6×6 button peeks through a checkerboard hole.
- The **disc** is Ø84 mm (14×14 "pixels" of 6 mm) and sticks out 13 mm. The tag sits in the center, so the disc works either way round.

**Disc: two slicer stops**
1. **Pause at Z = 1.6 mm**: drop an NTAG215 sticker into the hidden pocket, then resume.
2. **Filament change at Z = 3.0 mm**: the ring-shaped label prints in a bright color. Match it to the LED color in the automation.

Keep metal and magnets away from the PN532. The back speaker sits about 2 cm away, which is fine.

## Home Assistant setup

1. In the ESPHome Builder, create a device and paste `esphome/music-cube.yaml`. Add `music_cube_api_key`
   (generate a new one), `music_cube_ota_password`, `wifi_ssid` and `wifi_password` to `secrets.yaml`. Flash over USB once; after that, updates go over Wi-Fi.
2. In the ESPHome integration options for the device, enable **"Allow the device to perform Home Assistant actions"**.
   Without it, tags and events never reach HA.
3. Create a Text helper named `input_text.music_cube_last_disc`. The resume feature uses it.
4. Put audio files in `/media/cube/`, for example `/media/cube/stories/lullaby.mp3`.
5. Import `homeassistant/music_cube_automation.yaml` (Automations → Create → ⋮ → Edit in YAML).
6. **Link a disc:** insert a new disc and you get a notification with its ID. Add it to the `discs:` map with a `file` (or a Music Assistant `playlist`) and a `color`.

Tip: press **Write Tag Random** in HA and hold a disc to the reader. The disc becomes a regular Home Assistant tag
and shows up under Settings → Tags.

For **playlists and audiobooks**, [Music Assistant](https://music-assistant.io/) works best: it handles folders and playlists and remembers your position.
The automation already supports `playlist: "Name"` entries.

## Troubleshooting

- **Tag not read**: check that the PN532 is in I2C mode and screwed onto all 4 standoffs. Try a bare sticker right on the board.
  If reading is weak, reduce `standoff_h` or `slot_clear`.
- **No sound**: check 5 V on the MAX98357A and the LRC/BCLK/DIN order. Try playing something on `media_player.music_cube_player` from HA.
- **Choppy audio**: weak Wi-Fi. Move the jukebox closer to the router and check the logs to confirm PSRAM is detected.
- **Tag event arrives but nothing plays**: "Allow the device to perform Home Assistant actions" is not enabled.

## Credits

NFC tag handling is based on [adonno/tagreader](https://github.com/adonno/tagreader).
Minecraft is a trademark of Mojang/Microsoft. This is an unofficial fan project, not affiliated with them.

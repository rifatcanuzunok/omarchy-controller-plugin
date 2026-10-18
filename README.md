# Omarchy Xbox & Gamepad Controller Plugin 🎮

A native, lightweight status bar widget and popup panel for **[Omarchy](https://omarchy.org/)** (Hyprland / Quickshell). Displays connection status, model information, and real-time battery percentage for Xbox and other Bluetooth/USB gamepads.

---

## ✨ Features

- **🎯 Auto-Detection:** Automatically discovers paired Xbox and gamepad controllers via Bluetooth and USB wired connections — no hardcoded MAC addresses.
- **🔋 Real-time Battery Gauge:** Displays exact battery percentage (via BlueZ Battery Service & UPower) with an animated visual progress bar that alerts when battery is low.
- **🪟 Interactive Popup Panel:** Designed as a native Omarchy `KeyboardPanel`. Opens directly beneath the bar icon on click and dismisses when clicking anywhere outside or pressing `Esc`.
- **⚡ One-Click Controls:** Connect or disconnect your paired wireless controller with a single click directly from the panel.
- **🌐 Bilingual Localization (i18n):** Automatically detects your system language (`LANG`) and switches between **English** and **Turkish (Türkçe)**.
- **🎨 Native Aesthetics:** Styled using Omarchy's design language, typography, and dynamic theme colors (`qs.Commons.Style` and `qs.Commons.Color`).

---

## 📸 Preview

```text
 ┌────────────────────────────────────────────────────────┐
 │  󰊴   Xbox Controller                           %84     │
 │      CONNECTED (BLUETOOTH)                             │
 │  ────────────────────────────────────────────────────  │
 │  [██████████████████████████████████████░░░░░░]        │
 │  ────────────────────────────────────────────────────  │
 │  Model               Xbox Wireless Controller          │
 │  Connection          Bluetooth (Wireless)              │
 │  Battery Level       %84                               │
 │  ────────────────────────────────────────────────────  │
 │  [ 󰂲 Disconnect ]                       [ 󰑐 Refresh ]  │
 └────────────────────────────────────────────────────────┘
```

---

## 🚀 Installation

### Option 1: Via Omarchy CLI (Recommended)

Install directly using the built-in Omarchy plugin manager:

```bash
omarchy plugin add https://github.com/rifatcanuzunok/omarchy-controller-plugin --enable
```

To position it next to your network or bluetooth widget:

```bash
omarchy bar move rifatcanuzunok.controller --after omarchy.bluetooth
```

---

### Option 2: Manual Installation

Clone this repository into your user plugins directory:

```bash
git clone https://github.com/rifatcanuzunok/omarchy-controller-plugin.git ~/.config/omarchy/plugins/rifatcanuzunok.controller
chmod +x ~/.config/omarchy/plugins/rifatcanuzunok.controller/controller-status
```

Validate and enable the plugin:

```bash
omarchy plugin validate ~/.config/omarchy/plugins/rifatcanuzunok.controller
omarchy plugin enable rifatcanuzunok.controller --after omarchy.bluetooth
omarchy restart shell
```

---

## 🛠️ Linux & Controller Setup Guide

If your controller turns on but won't connect or show battery, follow these standard Linux tips:

### 1. Bluetooth Wireless (Xbox Series X|S / One)

Modern Xbox controllers communicate over BLE (Bluetooth Low Energy). For the best experience:

1. **Install `xpadneo`:**
   ```bash
   sudo pacman -S dkms linux-headers
   # Or via AUR (yay/paru):
   yay -S xpadneo-dkms
   ```
2. **Disable ERTM (Enhanced Retransmission Mode):**
   If the controller pairs but disconnects after 1-2 seconds, disable Bluetooth ERTM:
   ```bash
   echo 'options bluetooth disable_ertm=1' | sudo tee /etc/modprobe.d/xbox_bt.conf
   sudo modprobe -r bluetooth && sudo modprobe bluetooth
   ```
3. **Pair the controller:**
   - Turn on the controller (Xbox button).
   - Press and hold the small **Pairing (Sync)** button at the top for 3 seconds until the logo blinks rapidly.
   - Run `bluetoothctl`:
     ```text
     scan on
     pair <MAC_ADDRESS>
     trust <MAC_ADDRESS>
     connect <MAC_ADDRESS>
     ```

### 2. USB Wired Connection

If using a USB-C cable and the controller turns on but doesn't register as a joystick:
- Make sure `xpad` is **not blacklisted** in `/etc/modprobe.d/`:
  ```bash
  sudo rm -f /etc/modprobe.d/blacklist-xpad.conf
  sudo modprobe xpad
  ```

---

## 📁 Project Structure

```
rifatcanuzunok.controller/
├── manifest.json       # Omarchy plugin manifest schema (v1)
├── Controller.qml      # Main Quickshell bar widget and KeyboardPanel popup UI
├── I18n.js             # QML translation dictionary (English & Turkish)
├── controller-status   # Python backend helper (device discovery, battery, CLI)
├── LICENSE             # MIT License
├── README.md           # Documentation
└── .gitignore          # Git ignore rules
```

---

## 💻 CLI Commands

The helper script can also be run independently from the terminal:

```bash
# Output current controller status in JSON
~/.config/omarchy/plugins/rifatcanuzunok.controller/controller-status --json

# Trigger a desktop notification
~/.config/omarchy/plugins/rifatcanuzunok.controller/controller-status --notify

# Connect to paired Bluetooth controller
~/.config/omarchy/plugins/rifatcanuzunok.controller/controller-status --connect

# Disconnect active Bluetooth controller
~/.config/omarchy/plugins/rifatcanuzunok.controller/controller-status --disconnect
```

---

## 👤 Author

**Rıfatcan Uzunok**
- GitHub: [@rifatcanuzunok](https://github.com/rifatcanuzunok)

---

## 📜 License

Released under the [MIT License](LICENSE). Feel free to use, modify, and distribute!

# 🚀 ULTIMATE DOWNLOADER - SECURE PRO v1.0

<div align="center">

[img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white](https://www.gnu.org/software/bash/)
[img.shields.io/badge/Termux-000000?style=for-the-badge&logo=termux&logoColor=white](https://termux.dev/)
[img.shields.io/badge/yt--dlp-FF0000?style=for-the-badge&logo=youtube&logoColor=white](https://github.com/yt-dlp/yt-dlp)
[img.shields.io/badge/Security-Advanced-red?style=for-the-badge&logo=security&logoColor=white](#-security-system)
[img.shields.io/badge/License-Private-blue?style=for-the-badge](#-disclaimer)

**A Premium Termux Downloader with Military-Grade Key Verification System**

[Features](#-key-features) • [Installation](#-installation) • [Security](#-security-system) • [Admin Panel](#-admin-control-panel) • [Screenshots](#-screenshots)

</div>

---

## 💎 Key Features

| Category | Features |
| --- | --- |
| **🎬 Download Engine** | 1080p Best Quality, 720p HD, MP3 Audio, Images, Thumbnails |
| **🔐 Security Layers** | Device Lock, Key Expiry, Anti-Brute Force, Remote Kill Switch |
| **☁️ Admin Control** | Change key anytime, Force expire users, Ban management |
| **📱 Termux Optimized** | Mobile-first UI, History logs, Auto-update, Zero config |
| **⚡ Performance** | yt-dlp powered, Playlist support, Resume downloads |

---

## 🔐 Security System

This isn't a normal script. It uses **4-Layer Protection** to prevent unauthorized access:

**1. Online Key Verification**
Key is never stored in script. Every launch fetches from `key.txt` on GitHub. No internet = No access.

**2. Device Fingerprinting**
First successful login creates `~/.vd_device_lock`. Next time key won't be asked. Unique per device.

**3. Expiry Date Enforcement**
Admin sets `expiry` in JSON. App auto-locks after date. Format: `YYYY-MM-DD`

**4. Anti-Brute Force System**
3 wrong attempts = 1 hour ban. Ban file stored at `~/.vd_ban`. Prevents key guessing attacks.

---

## 📥 Installation

**Requirements:** Termux from F-Droid only. Play Store version is deprecated.

```bash
pkg update -y && pkg upgrade -y
pkg install git python ffmpeg -y
pip install -U yt-dlp
git clone https://github.com/niranjanpal1/downloader.git
cd downloader
chmod +x vd.sh
./vd.sh

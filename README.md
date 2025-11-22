# AdAway Mount Helper

Minimal systemless hosts mount helper for APatch, KernelSU and Magisk.

## About

This module is inspired by [bindhosts](https://github.com/bindhosts/bindhosts) but stripped down to only the essential mount functionality needed to enable [AdAway](https://github.com/AdAway/AdAway) to work with modern root managers.

**What was removed:**
- WebUI and action button control
- Built-in ad-blocking engine
- Automatic hosts list updates
- Multiple redirect methods (kept only essential mount modes)
- Cron scheduling
- Translation files and multi-language support

**What remains:**
- Operating mode detection for various root managers
- Proper mount strategy selection
- AdAway compatibility layer
- Support for SUSFS, ZygiskNext, and other denylist handlers

## Purpose

This module does **not** block ads by itself. It simply prepares the mount infrastructure so that AdAway can manage the hosts file properly across different root managers and configurations.

## Supported Root Managers

- [APatch](https://github.com/bmax121/APatch)
- [KernelSU](https://github.com/tiann/KernelSU)
- [Magisk](https://github.com/topjohnwu/Magisk)

## Installation

1. Install this module through your root manager
2. Install [AdAway](https://github.com/AdAway/AdAway)
3. AdAway will automatically detect and use the prepared mount point

## Credits

Based on the excellent work by the [bindhosts project](https://github.com/bindhosts/bindhosts).

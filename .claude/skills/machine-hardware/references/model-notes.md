# Model Notes — Alienware m18 R1 AMD (community / online research)

Facts about the m18 R1 AMD as a *model*, gathered from Dell docs and the Linux community (Arch forums, LinuxQuestions, NotebookTalk, personal blogs). **Confidence is marked per item** — "✓ this box" = confirmed on the user's actual unit; "model" = reported for the model, not verified here. Cross-checked against the empirically-found fixes in `quirks-and-fixes.md`, which always win.

---

## ⚠️ Two different variants — don't mix up their Linux advice

The m18 R1 AMD ships in **two GPU configurations**, and most online Linux write-ups are for the *other* one:

| Variant | dGPU | This user? |
|---|---|---|
| **"AMD Advantage" (all-AMD)** | Radeon **RX 7600M XT** (`amdgpu`) | ❌ no |
| **NVIDIA** | GeForce **RTX 4070 / 4080** Laptop (`nvidia`) | ✅ **yes — RTX 4070** |

**Consequence:** a large fraction of "m18 R1 AMD Linux" content describes `amdgpu`-specific pain that **does not apply here**, e.g.:
- `amdgpu.runpm=0 pcie_aspm=off` kernel params for GPU switching
- PSP resume failures ("PSP load kdb failed" / "PSP resume failed")
- `AMD-Vi IO_PAGE_FAULT`, GPU ring timeouts, `amdgpu` parser `-125` failures
- Steam `.desktop` `PrefersNonDefaultGPU` tweaks for AMD PRIME

On this box Optimus is off and NVIDIA is the only dGPU — ignore amdgpu-GPU advice; use the NVIDIA config in `hardware-modifications.nix`. (The 7845HX's integrated Radeon 610M still exists but its display path is unused.)

---

## Chassis / spec facts (Dell)

- **CPU:** Ryzen 9 7845HX — 12C/24T, 64 MB L3, up to ~5.2 GHz boost, family `0x19` model `0x61` (relevant to microcode; config sets `hardware.cpu.amd.updateMicrocode`). ✓ this box (7845HX). *Note: some listings/Micro Center pair the m18 R1 AMD with a 7945HX — this unit is the 7845HX.*
- **Panel:** this unit is the **18" FHD+ 1920×1200, 480 Hz, 3 ms** ComfortView-Plus / 100% DCI-P3 panel. ✓ this box (sysfs shows 120/240/480 Hz modes on the BOE eDP). A **QHD+ (2560×1600)** panel was the other factory option — not this machine.
- **Cooling:** "Cryo-tech" — quad-fan, vapor-chamber, Element-31 (gallium-silicone) thermal interface, rear/side exhaust. Expect **loud fans under load**; only one ACPI thermal zone is exposed to Linux (`acpitz`). model.
- **BIOS:** Insyde **InsydeH2O** (UEFI). This unit is on **1.18.0** (2025-04-16). ✓ this box. **⚠️ Not the latest** — Dell's site publishes newer (1.19 Aug 2025 → **1.22.009** Mar 2026); these are **not** mirrored to LVFS/fwupd, so update via **F12 → BIOS Flash Update** from a FAT32 USB (no Windows needed). Downgrades are blocked (one-way). This is the untried firmware lever for the s2idle suspend bug — see quirks-and-fixes.md §Suspend.

### Ports (Dell spec — model)
- **1× HDMI 2.1**, **1× mini-DisplayPort** — external video also routes through the NVIDIA GPU (matches the single `HDMI-A-1` connector seen in sysfs).
- **2× USB-C (USB 3.2 Gen 2) with DisplayPort Alt-Mode**, **1× USB-C (Gen 1)** — usable for external displays / docks. (These hang off the flaky ASMedia USB4 controller — see the USB4 note in `quirks-and-fixes.md`/`hardware-inventory.md`.)
- **USB-A**: 3× USB 3.2 Gen 1, one with **PowerShare** (ties into the BIOS *USB PowerShare / USB Wake* options implicated in the USB4 stay-powered quirk).
- **1× RJ45** (the Realtek RTL8125 2.5 GbE, `enp8s0`), **1× universal audio jack**.

---

## Model-level Linux quirks (verify before acting)

- **"Won't boot on battery below ~70%"** — a **documented m18 R1 AMD quirk** (multiple Fedora reports): the machine refuses to POST/boot Linux when on battery below a threshold. Mitigation is generally "boot on AC / keep charged," and check for a BIOS update. *This user runs desktop-style, always plugged in (per the flicker memory), so it rarely bites — but it explains any "dead on battery" symptom.* model.
- **ACPI DSDT complaints at boot** — the model logs ACPI BIOS errors / DSDT corruption and "lid device not compliant to SW_LID." Community workaround: `acpi=copy_dsdt` kernel param. **Not currently needed here** (no functional impact observed); note it only if ACPI misbehavior appears. model.
- **`dell_smbios: Unable to run on non-Dell system`** — Alienware isn't on Dell's officially-supported-for-Linux list, so some Dell/`dell_smbios` tooling refuses to load. Expected, mostly cosmetic. model.
- **UCSI / USB-C PD** — `UCSI_GET_PDOS failed` / `PPM init failed -ETIMEDOUT` on the Type-C controller has been reported; correlates with the ASMedia USB4 flakiness already documented. model.
- **Internal mic / HDA** — some units report the dual-array mic non-functional and HDA codec init warnings on early kernels; generally improved on newer kernels. Re-check on the current Zen kernel if the mic is ever needed. model.

---

## RGB keyboard (AlienFX) & fan control on Linux

- **OpenRGB largely cannot drive** the m16/m18 R1 AlienWare keyboard LEDs. model.
- Community tools that do work via Alienware's ACPI/AWCC function calls (not raw EC pokes):
  - **`tr1xem/alienfx-linux`** — Linux SDK, per-key + per-device effects, targets Dell/Alienware/G-series 2010–2025.
  - **`T-Troll/alienfx-tools`** — lights + **fan/power** control using the same proprietary ACPI calls AWCC uses.
- Neither is packaged in this NixOS config today. If the user wants RGB or software fan curves on Linux, these are the starting points (would need a Nix package / overlay).

---

## Sources

- [Dell — m18 R1 AMD Setup & Specifications](https://www.dell.com/support/manuals/en-us/alienware-m18-r1-amd-laptop/alienware-m18r1-amd-setup-and-specifications/processor)
- [Dell — m18 R1 AMD Usage & Troubleshooting Guide](https://www.dell.com/support/kbdoc/en-us/000212590/alienware-m18-r1-amd-usage-and-troubleshooting-guide)
- [Arch Linux Forums — Dell Alienware M18 R1 AMD / Laptop Issues](https://bbs.archlinux.org/viewtopic.php?id=288806)
- [LinuxQuestions — m18 R1 AMD won't boot on battery below 70%](https://www.linuxquestions.org/questions/linux-laptop-and-netbook-25/alienware-m18-r1-amd-won't-boot-on-battery-below-70-a-4175725567/)
- [Russel Taylor — Alienware M18 R1 AMD & Linux](https://russeltaylor.com/2024/04/25/alienware-m18-r1-amd-linux/) (note: AMD-GPU variant)
- [github.com/tr1xem/alienfx-linux](https://github.com/tr1xem/alienfx-linux/) · [github.com/T-Troll/alienfx-tools](https://github.com/T-Troll/alienfx-tools)

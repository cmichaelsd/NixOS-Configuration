---
name: machine-hardware
description: Expert reference for this user's physical machine — an Alienware m18 R1 AMD laptop (Ryzen 9 7845HX + NVIDIA RTX 4070 Laptop, discrete-only, s2idle-only firmware). Covers the exact hardware inventory (device IDs, PCI paths, connectors), and the hard-won quirks and fixes for this specific model: NVIDIA backlight/brightness control, the panel refresh/flicker situation, the s2idle suspend-bounce saga, HDMI brightness via ddcutil, the SD-card-reader wake, USB4/Thunderbolt flakiness, and BIOS-level constraints. Use whenever the user asks about "my machine / this computer / this laptop / the hardware," reports a hardware-level symptom (brightness, sleep/suspend/wake, display flicker, battery, thermals, wifi/bluetooth, USB/Thunderbolt, SD reader), or is editing modules/hosts/my-machine/*.nix (boot.nix, hardware-modifications.nix, hardware-configuration.nix) — also trigger when they describe a laptop-firmware or driver symptom without naming the model.
---

# Machine Hardware — Alienware m18 R1 AMD

This is the user's physical laptop. It is a **discrete-GPU-only** gaming laptop with **AMD firmware quirks** that have cost real debugging hours — several "obvious" Linux fixes (ACPI GPE masking, per-device `power/wakeup`, WMI-EC backlight) **do not work on this hardware** and are documented as dead ends below so they are never re-attempted.

> **Golden rule:** the fixes here were found empirically on *this* machine. Prefer them over generic Arch-wiki / forum advice for the same symptom — the generic advice was usually already tried and failed (see the "Disproven" lists).

---

## Identity

| | |
|---|---|
| **Model** | Alienware m18 R1 **AMD** (not the Intel m18 R1) |
| **Vendor / board** | Alienware / board `0WGV87` |
| **BIOS** | `1.23.0`, dated 2026-03-30 (`/sys/class/dmi/id/bios_version`) — flashed up from 1.18.0; expect a black screen on next flash, see quirks §BIOS-flash |
| **CPU** | AMD **Ryzen 9 7845HX** (Zen 4, 12C/24T, integrated Radeon) |
| **dGPU** | NVIDIA **GeForce RTX 4070 Laptop** (Ada), 8 GB VRAM |
| **RAM** | 32 GB (≈31 GiB usable) |
| **Storage** | KIOXIA `KXG80ZNV1T02` 1 TB NVMe (`nvme0n1`, 3 partitions) |
| **Panel** | BOE **eDP-1**, 1920×1200 (FHD+), 120/240/480 Hz modes, VRR-capable |
| **Battery** | BYD cells, Dell P/N `53XP73A` |
| **Kernel** | `linuxPackages_zen` (Zen kernel) |

**Optimus is disabled in BIOS** → the machine runs **discrete NVIDIA only** (no hybrid/PRIME muxing). This is why NVIDIA drives the internal panel backlight directly and why there's no `amdgpu` display path to fall back on.

> **⚠️ Variant trap:** the m18 R1 AMD ships in two GPU flavors — an **"AMD Advantage" all-AMD** version (Radeon RX 7600M XT) and this **NVIDIA** version (RTX 4070). Most "m18 R1 AMD Linux" write-ups online are for the *AMD-GPU* one, so their fixes (`amdgpu.runpm=0`, PSP-resume errors, AMD-Vi page faults, PRIME Steam tweaks) **do not apply here**. See references/model-notes.md before importing any online advice.

Full device-ID / PCI-path inventory: **references/hardware-inventory.md**.

---

## Applied Config (source of truth)

Everything hardware-specific lives under `modules/hosts/my-machine/`:

- **`hardware-modifications.nix`** — NVIDIA (open module, modesetting, stable pkg, powerManagement), i2c, bluetooth, graphics, amd microcode, GBM/VAAPI session vars.
- **`boot.nix`** — `kernelParams` (`nvidia-drm.fbdev=1`), systemd-boot, `linuxPackages_zen`.
- **`hardware-configuration.nix`** — generated; filesystems, kernel modules.

Both `boot.nix` and `hardware-modifications.nix` carry **"do NOT re-add" warning comments** guarding the suspend saga. Respect them.

Read the actual files for current state — don't trust this snapshot, it drifts.

---

## The Big Quirks (one-line triage)

| Symptom | Status | Where |
|---|---|---|
| Panel brightness keys / `brightnessctl` | **SOLVED** — `nvidia_0` is the only backlight, drives the panel | quirks §Backlight |
| HDMI external-monitor brightness | **SOLVED** — `hardware.i2c.enable` + ddcutil | quirks §HDMI |
| Occasional brief black flashes on panel | **PARKED** — cosmetic, many levers exhausted | quirks §Flicker |
| Machine won't stay asleep (bounces out of s2idle ~13 s) | **WORKED AROUND** — auto-suspend disabled; root cause is firmware | quirks §Suspend |
| Lock screen lighting up overnight | **SOLVED** — was SD reader (gpe10) + suspend loop | quirks §Suspend |

Full detail, evidence, and the **disproven** approaches: **references/quirks-and-fixes.md**. Read it before touching sleep, backlight, or GPE/wakeup config — it will save you from re-running dead ends.

---

## Hard Constraints (memorize these)

- **Sleep is `s2idle` only.** `/sys/power/mem_sleep` = `[s2idle]` — the firmware exposes **no deep S3**. All suspend behavior is low-power-idle (S0i3).
- **The machine cannot reliably hold s2idle.** A firmware-programmed `amd_gpio` level-triggered S0i3 wake pin (on `pinctrl_amd`, IRQ 7) re-fires ~13 s after every suspend. It is **not** an ACPI GPE and **not** reachable by any Linux toggle. → auto-suspend is turned off (`noctalia.json` `idle.suspendTimeout = 0`); the machine locks + blanks the screen but stays running.
- **Hibernate is infeasible** as configured: 31 GiB RAM vs only ~8.8 GiB swap (`nvme0n1p3`).
- **RTC gotcha:** `rtc0` is an ACPI TAD with no working `wakealarm`; the usable CMOS RTC is **`rtc1`**. For any `rtcwake` test, pass `-d /dev/rtc1`.
- **Backlight:** only `/sys/class/backlight/nvidia_0` exists and it genuinely moves the panel. Do **not** add `nvidia_wmi_ec_backlight force=Y` (registers a fake device that accepts writes but doesn't dim).

---

## Diagnostic Tooling on this box

- `lspci` is **not installed** by default — read PCI info from `/sys/bus/pci/devices/*` or `lshw`/`nix run nixpkgs#pciutils`.
- ACPI wakeup sources: `/proc/acpi/wakeup`, `/sys/firmware/acpi/interrupts/gpe*`, `/sys/kernel/debug/wakeup_sources`.
- GPIO wake pins: `/sys/kernel/debug/gpio` (look for the ⏰ S0i3 column).
- s2idle residency: `/sys/kernel/debug/amd_pmc/s0ix_stats` (proves the box *does* reach deep sleep).
- Decompile ACPI tables: `nix shell nixpkgs#acpica-tools -c iasl -d <table>` — on this box the GPE handlers live in **SSDTs**, not the DSDT.

---

## Reference Files

Read on demand — don't load speculatively.

- **references/hardware-inventory.md** — full component list with PCI paths, vendor:device IDs, network/USB4/SD-reader/audio details, connectors, partitions.
- **references/quirks-and-fixes.md** — the complete saga for each quirk: symptom, root cause, the working fix, and (critically) the list of approaches that were **disproven** on this hardware so you don't repeat them.
- **references/model-notes.md** — model-level facts from online research (Dell specs, community Linux reports): the AMD-vs-NVIDIA variant trap, ports (HDMI 2.1 / mini-DP / USB-C DP-alt), the "won't boot on battery <70%" quirk, InsydeH2O BIOS, RGB/fan-control tooling (alienfx-linux). Marked "✓ this box" vs "model" for confidence.

Deeper narrative history also lives in the user's memory files (`project_brightness_fix`, `project_screen_flicker`, `project_noctalia_suspend_wake_cycle`, `project_lockscreen_wake_diagnosis`, `project_hdmi_brightness`).

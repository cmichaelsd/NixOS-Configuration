# Quirks & Fixes — Alienware m18 R1 AMD

Each section: **symptom → root cause → working fix → disproven approaches (do not repeat)**. These were found empirically on *this* machine. The "disproven" lists are the point — they are the generic advice you'll be tempted to try again.

Deeper blow-by-blow history is in the user's memory files (linked per section).

---

## §Backlight — internal panel brightness  ✅ SOLVED

**Symptom:** brightness keys / `brightnessctl` didn't dim the panel.

**Root cause:** with Optimus off, the panel backlight is owned by the NVIDIA GPU, not any ACPI/amdgpu path. The kernel needs `nvidia-modeset` to register the backlight honestly.

**Working fix (in `hardware-modifications.nix`):**
- `hardware.nvidia.modesetting.enable = true`
- **No** `boot.extraModprobeConfig` for `nvidia_wmi_ec_backlight` — let nvidia-modeset register the device.
- Result: `/sys/class/backlight/nvidia_0` is the **only** backlight device and genuinely moves the panel.

**Disproven:**
- `nvidia_wmi_ec_backlight force=Y` — registers a fake `/sys/class/backlight` entry that accepts writes (`actual_brightness` updates) but **does not** move the panel. This was the original bug. Never re-add it.
- `acpi_backlight=none` — suppressed the nvidia-modeset fallback too. `acpi_backlight=native` was tried and turned out **unnecessary** (only `nvidia_0` registers, no competitor to arbitrate). `acpi_backlight=video`/`vendor` — Alienware `_BCM` references a missing `AFN7` symbol; the ACPI video path is broken.
- `NVreg_EnableBacklightHandler=1` — not a real NVIDIA parameter.

**If it regresses** (e.g. after a driver bump): `ls /sys/class/backlight/` should show `nvidia_0`. If it vanishes, first lever is re-adding `acpi_backlight=native` to `kernelParams`; then `amdgpu.backlight=1`. Verify no `nvidia_wmi_ec_backlight` modprobe option snuck back.

Memory: `project_brightness_fix`.

---

## §HDMI — external monitor brightness  ✅ SOLVED

**Symptom:** `ddcutil` got `EACCES` on `/dev/i2c-*`; couldn't set external-monitor brightness.

**Root cause:** `i2c-dev` was loaded but device nodes had restrictive permissions; no `i2c` group udev rules.

**Working fix:** `hardware.i2c.enable = true` in `hardware-modifications.nix` (creates the `i2c` group + udev rules; user is in `i2c`). Needs rebuild + reboot. Verify with `ddcutil detect`. The niri keybinds use `ddcutil setvcp 10 +/- 5` (VCP feature 0x10 = luminance).

Memory: `project_hdmi_brightness`.

---

## §Flicker — brief black flashes on panel  ⏸ PARKED (cosmetic)

**Symptom:** brief (~single-frame) black flashes, roughly every 6–10 min of desktop use. Uptime-correlated, not load-correlated. NVIDIA + Wayland (niri) + Ada.

**Status: PARKED.** Not worth infinite spelunking. Many levers exhausted:

**Disproven (flicker survived all of these):**
- `nvidia-drm.fbdev=1` (kept, harmless), `NVreg_EnableGpuFirmware=0` (GSP disable), PowerMizer pinned via `NVreg_RegistryDwords`, `hardware.nvidia.powerManagement.enable`, niri `debug.disable-cursor-plane` / `disable-direct-scanout`.
- `hardware.nvidia.open = true` (kept — recommended for Ada), `acpi_backlight=native` removal.
- nvidia `stable ↔ beta` swap (beta was *older*, buggier), shader-cache/boot-entry state-drift cleanup.
- Panel refresh pin experiment: BOE eDP-1 EDID-preferred is 120 Hz; tried pinning 240 Hz via `outputs."eDP-1".mode`.

**Unexplored levers if ever revisited:** nvidia `production` once the channel diverges from `stable`; a different kernel (LTS or `linuxPackages_latest`) vs the current Zen kernel; an X11 session for compositor-vs-driver bisection.

**Driver-version caution:** `nvidia-smi` version has disagreed with the pinned `nvidiaPackages.stable` when no reboot happened. Confirm the *built* version with:
`nix eval '/etc/nixos#nixosConfigurations.myMachine.config.boot.kernelPackages.nvidiaPackages.stable.version'`

Memory: `project_screen_flicker`.

---

## §Suspend — machine won't stay asleep  🔧 WORKED AROUND (firmware bug)

**This is the big one.** Read before touching *anything* sleep/wake/GPE/`power/wakeup` related.

**Symptom:** overnight the lock screen lights up ~2×/hr; deeper diagnosis showed the machine **bounces out of s2idle ~13 s after every suspend** (`suspend entry` → `suspend exit` ~13 s apart, then a 30-min gap = the idle-suspend retry). It reaches deep sleep fine (`amd_pmc/s0ix_stats` confirms ~8 s entry/exit) — it just can't *stay* there.

**Root cause (definitive):** a **firmware-programmed `amd_gpio` level-triggered S0i3 wake pin** (pins #58/#59/#61/#62 in `/sys/kernel/debug/gpio`) on `pinctrl_amd`, surfacing as **IRQ 7** (a raw GPIO line into the IO-APIC that **bypasses the ACPI SCI**). A held-asserted level IRQ re-fires immediately → the consistent ~13 s bounce. Decompiling the DSDT + all 26 SSDTs shows **zero `GpioInt`/`_AEI` declarations** for these pins → BIOS programs them straight into the amd_gpio wake registers, so **no Linux driver owns them and no `power/wakeup` toggle or kernel param can clear them.**

**Working fix (accept the constraint):** disable auto-suspend. `noctalia.json` → `idle.suspendTimeout = 0`. The screen still **locks** (`lockTimeout = 600`) and **blanks** (`screenOffTimeout = 660`); the machine simply stays running. This is the pragmatic path the user chose over broken sleep.

**Disproven — the entire "disarm the waker" strategy failed:**
- **`acpi_mask_gpe=…`** — the GPE approach is a dead end here because the waker is *not* a GPE. Even so, note the syntax trap discovered along the way: `acpi_mask_gpe` takes **one GPE per occurrence and must be repeated** (`"acpi_mask_gpe=0x04" "acpi_mask_gpe=0x08" ...`) — a comma list (`0x04,0x10`) is parsed as a single bad token and **silently masks nothing**. `mask` (not `disable`) is the correct primitive for a GPE, but irrelevant here. All of 0x04/0x08/0x10/gpe09 were masked and confirmed 0 fires → **still bounced** (`pm_wakeup_irq=7`).
- **The GPE red herrings:** gpe04 self-labeled `DiscreteUSB4`, gpe08 = NVIDIA dGPU port, gpe10 = SD reader, gpe09 = AMD-GPIO aggregate SCI. Each looked like "the" waker in turn; masking each just shifted the count to the next. gpe09 can't be the fix because IRQ 7 bypasses the SCI entirely.
- **`power/wakeup=disabled`** on the USB4 functions (`1b21:242a/b/c`), the NVIDIA port, the HID devices, and finally **all 18 wake-armed nodes** — still bounced. No device remote-wakeup governs it.
- **`systemd.tmpfiles` `w .../gpeNN - - - - disable\n`** — the ACPI GPE sysfs handler **rejects the write with EINVAL** for both the literal-`\n` and no-newline cases in the tmpfiles context. (This silently never applied; an earlier "working" gpe10 read was stale from a prior boot's live `echo`.) Do not trust tmpfiles for GPE sysfs.
- **`powerManagement.powerDownCommands` `echo disable > .../gpeNN`** — refused EINVAL *inside the pre-suspend hook window*; and even a successful disable gets **re-armed on resume** by the flaky USB4 controller.

**Related, genuinely SOLVED earlier:** the SD-card reader (`rtsx_pci`, GPE **0x10**) *was* a real overnight waker in an earlier era and its bounce is a distinct issue from the amd_gpio one. That was handled while the GPE strategy still looked viable; with auto-suspend now off, the point is moot, but **do not re-introduce SD-reader wakeup config** expecting it to help the current bounce.

**Testing recipe (if you ever revisit):**
- `sudo rtcwake -m mem -s 30 -d /dev/rtc1` (**must** use `rtc1`) — a good suspend stays down the full 30 s; the bug bounces at ~13 s.
- Snapshot `/sys/firmware/acpi/interrupts/gpe*` before/after; check `/sys/power/pm_wakeup_irq` (7 = pinctrl_amd/GPIO, 9 = ACPI SCI).
- Confirm deep-sleep entry via `/sys/kernel/debug/amd_pmc/s0ix_stats`.

**Remaining real options (none applied, user leaning to "just don't suspend"):** (1) a **BIOS/firmware update** — cleanest for a firmware wake bug (see below — a newer BIOS exists and is UNTRIED); (2) `devmem`-poke the amd_gpio wake register pre-suspend to clear #58/59/61/62 — hacky, may re-arm, risks killing wake-on-keyboard/touchpad if those *are* the pins; (3) the current choice — no auto-suspend, lock+blank only.

**BIOS-update lever — NOT exhausted (checked 2026-07-12):**
- `services.fwupd.enable = true` was added (`modules/nixos/services.nix`). But **LVFS has no BIOS update** for this machine — `fwupdmgr get-updates` shows `System Firmware` under "no available updates" (only offers an unrelated UEFI **dbx** Secure-Boot revocation update — skip it). Alienware doesn't publish BIOS to LVFS.
- **Dell's support site DOES have newer BIOS**, several versions past the installed **1.18** (Apr 2025): **1.19.014** (Aug 2025), **1.20.018** (Nov 2025), **1.21.011** (Dec 2025), **1.22.009** (Mar 2026 — latest). This firmware lever is therefore **untried, not dead.**
- Release notes are generic (security/thermal/audio/stability) — **no explicit "S0i3 spurious wake" fix noted**, so no guarantee it fixes the bounce; but the root cause is firmware, so it's the best remaining shot.
- **Flashing without Windows** (this box is Linux-only): download the latest `.exe` → FAT32 USB → reboot → **F12 → BIOS Flash Update**. fwupd cannot do it.
- **Caveats:** downgrades are **blocked** (one-way); flash on **AC** (recall the "won't boot on battery <70%" quirk); settings may reset — re-verify **Optimus disabled** + USB Wake/PowerShare afterward. If a new BIOS fixes the bounce, revisit `noctalia.json suspendTimeout=0` (re-enable real suspend).

**Guard rails already in the tree:** both `boot.nix` and `hardware-modifications.nix` carry explicit "do NOT re-add `acpi_mask_gpe`/USB4 wakeup udev rules" comments. Honor them.

**Applying noctalia config:** the wrapper bakes `NOCTALIA_SETTINGS_FILE` into the running `quickshell` env at launch — a `nixos-rebuild switch` does **not** update a running shell. Restart Noctalia (kill the `quickshell` pid, respawn via `niri msg action spawn`) or log out/in. The mutable `~/.config/noctalia/settings.json` is an unused leftover in this mode.

Memory: `project_noctalia_suspend_wake_cycle`, `project_lockscreen_wake_diagnosis`.

---

## §Startup-vs-rebuild gotcha (bites every sleep/niri experiment)

niri's `spawn-at-startup` (idle-logger, noctalia, etc.) only fires at **niri launch**. A `nixos-rebuild switch` does **not** restart the running compositor — config touching niri startup or the shell needs a **log out / log in**. This has cost multiple overnight test runs. Related: memory `feedback_reboot_pending_memory`.

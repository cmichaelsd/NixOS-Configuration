# Hardware Inventory — Alienware m18 R1 AMD

Concrete component list with driver names, PCI paths, and `vendor:device` IDs (as read from `/sys/bus/pci/devices/*`). Use these IDs when writing udev rules, modprobe options, or when matching a device in diagnostics. IDs are stable; drivers/paths can shift across kernel bumps — re-verify with the sysfs loop in the SKILL if something looks off.

## Platform / firmware

- **Model string:** `Alienware m18 R1 AMD` (`/sys/class/dmi/id/product_name`)
- **Board:** `0WGV87`
- **BIOS:** `1.18.0`, 2025-04-16
- **fwupd:** not installed (no LVFS firmware-update path configured)
- **Sleep states:** `/sys/power/mem_sleep` = `[s2idle]` only — **no S3 "deep"**. `Low-power S0 idle used by default`.

## CPU / memory

- **CPU:** AMD Ryzen 9 7845HX — Zen 4 (Dragon Range), 12 cores / 24 threads. `hardware.cpu.amd.updateMicrocode = true`.
- **iGPU:** Radeon 610M integrated in the 7845HX — present in silicon but the **display path is unused** (Optimus off; NVIDIA drives everything).
- **RAM:** 32 GB total (~31 GiB usable).
- **Swap:** ~8.8 GiB on `nvme0n1p3` — too small for hibernate against 31 GiB RAM.

## GPU / display

| Device | ID | PCI | Driver |
|---|---|---|---|
| NVIDIA RTX 4070 Laptop (Ada) | `10de:2860` | `0000:01:00.0` | `nvidia` |
| NVIDIA HDMI/DP audio | `10de:22bd` | `0000:01:00.1` | `snd_hda_intel` |

- **Optimus disabled in BIOS** → discrete-only, no PRIME/mux.
- **Backlight:** `/sys/class/backlight/nvidia_0` is the **only** backlight device and it drives the panel (see quirks §Backlight).
- **Internal panel:** BOE, connector **`eDP-1`**, native 1920×1200 (FHD+), EDID product `NE18NZ1`. Reports modes at **120 / 240 / 480 Hz**; VRR capable (disabled). NVIDIA-recommended `open` kernel module is in use for this Ada GPU.
- **External:** connector **`HDMI-A-1`** (routed through the NVIDIA GPU). External brightness is done over DDC/CI (ddcutil), see quirks §HDMI.

## Storage

- **NVMe:** KIOXIA `KXG80ZNV1T02` 1 TB (`/dev/nvme0n1`), partitions `p1` (ESP), `p2` (root), `p3` (swap).

## Networking

| Device | ID | PCI | Driver | Iface |
|---|---|---|---|---|
| Realtek RTL8125 2.5 GbE | `10ec:8125` | `0000:08:00.0` | `r8169` | `enp8s0` |
| Qualcomm Wi-Fi (ath11k) | `17cb:1103` | `0000:06:00.0` | `ath11k_pci` | `wlp6s0` |

- **Bluetooth:** enabled, `powerOnBoot = true` (paired with the Qualcomm combo card).
- Docker bridges (`docker0`, `br-*`) also appear in `ip link` — not physical.

## USB / Thunderbolt / SD

| Device | ID | PCI | Driver | Notes |
|---|---|---|---|---|
| ASMedia USB4 upstream port | `1b21:242a` | `0000:03:00.0` | `pcieport` | discrete USB4/TB controller |
| ASMedia USB4 downstream port | `1b21:242b` | `0000:04:02.0` | `pcieport` | |
| ASMedia USB4 xHCI | `1b21:242c` | `0000:05:00.0` | `xhci_hcd` | **flaky** — runtime-suspend fails `-110` ("Clearing Run/Stop bit failed"); stays powered. Tied to BIOS **USB PowerShare / USB Wake**. |
| AMD xHCI | `1022:15b6` | `0000:09:00.3` | `xhci_hcd` | |
| AMD xHCI | `1022:15b7` | `0000:09:00.4` | `xhci_hcd` | |
| AMD xHCI | `1022:15b8` | `0000:0a:00.0` | `xhci_hcd` | |
| Realtek RTS5260 SD reader | `10ec:525a` | `0000:07:00.0` | `rtsx_pci` | `mmc0`; was an overnight wake source via **GPE 0x10** (gpe10) — see quirks §Suspend. |

## Audio

| Device | ID | PCI | Driver |
|---|---|---|---|
| AMD HD Audio (analog/speakers) | `1022:15e3` | `0000:09:00.6` | `snd_hda_intel` |
| NVIDIA HDMI audio | `10de:22bd` | `0000:01:00.1` | `snd_hda_intel` |

## Power / battery / thermal

- **Battery:** BYD cells, Dell part `53XP73A`. Reports via `/sys/class/power_supply/BAT*`.
- **Thermal:** single ACPI thermal zone (`acpitz`) exposed to Linux; per-core/GPU sensors via `lm_sensors` / `nvidia-smi`. This is a high-TDP gaming chassis — expect aggressive fans under load.
- **RTC:** `rtc0` = ACPI TAD (no working `wakealarm`); **`rtc1`** = CMOS RTC with a functioning alarm — use `-d /dev/rtc1` for `rtcwake`.
- **GPIO wake pins:** `/sys/kernel/debug/gpio` shows firmware-armed S0i3 wake pins **#58/#59/#61/#62** (level) and #0/#3/#4 (edge) on `pinctrl_amd` — the root of the suspend-bounce (quirks §Suspend).

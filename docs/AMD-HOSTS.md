# Running macOS guests on an AMD host

This fork boots macOS on AMD hardware. The configuration below was arrived at empirically on an
AMD Ryzen 7 PRO 6850H (Zen 3+, family 19h) under Unraid 7.2.4, and several parts of it are
counter-intuitive. **Do not "tidy" them without reproducing the failure first.**

The `smoke-image` CI job asserts the load-bearing strings, so a regression fails the build rather
than surfacing later as a guest that will not boot. This file explains why they matter.

## The configuration

| setting | value | why |
|---|---|---|
| CPU args | `Cascadelake-Server,vendor=GenuineIntel,+invtsc,kvm=on,vmware-cpuid-freq=on` | `-cpu host` passthrough does NOT boot macOS multi-core on AMD. It dies in `_cpu_thread_alloc`. A named Intel model plus the vendor spoof makes the guest genuinely look Intel. |
| bootloader | `opencore-osx-proxmox-vm.iso.gz` | carries the algrey `cpuid_set_cpufamily` patches. The bundled `OpenCore-v21.iso.gz` carries none. |
| core count | **powers of two only** | verified single-variable with memory held constant: 6 cores hangs at a grey Apple logo with one core pinned at 99%, 8 boots. |
| topology | `sockets=1 cores=N threads=1`, `topoext` removed | libvirt's host-passthrough `dies`/`clusters` form confuses macOS. No Mac ever shipped four sockets. |
| MaxKernel | `25.99.99` on the cpufamily patch | was `22.99.99`, which is Ventura only. This one field is what unlocked Sonoma, Sequoia and Tahoe. |

Implemented in `Macinabox/run/unraid.sh` as `AMD_CPUARGS`, applied by `apply_host_cpu_profile()`,
which resolves the host vendor from `/proc/cpuinfo` (`AuthenticAMD` / `GenuineIntel`).

## Why the patch set is deliberately minimal

Under KVM with a named Intel model plus the vendor spoof, the guest already looks Intel, so most
AMD_Vanilla patches are irrelevant. **Installing the full 26-patch bare-metal set regressed a
working boot.** Do not add them.

Exactly one MaxKernel field was changed. The other `22.99.99` entry is "Force FileVault on Broken
Seal", an OCLP patch scoped to non-AVX2 Ventura; widening it would apply a Ventura-specific
workaround to newer releases, so it stays. The four inert `Source/EFI-*` variants inside the image
are untouched, because Macinabox boots `EFI/OC` only.

## Verified on this hardware

| macOS | kernel | state reached |
|---|---|---|
| Ventura 13 | 22 | full desktop |
| Sonoma 14 | 23 | installed; boot verified at 4 vCPU during the MaxKernel change |
| Sequoia 15 | 24 | installed, through Setup Assistant |
| Tahoe 26 | 25 | installed, reaches login screen (8 vCPU, 16 G RAM, vgamem 64 MB) |

## Practical limits worth knowing

- **GPU acceleration may not be achievable.** On a host whose only adapter is an integrated Radeon
  680M (RDNA2), macOS has no driver and it is the host's only display, so passthrough is not
  viable. macOS then runs on the VESA framebuffer over VNC, and resolution is set in OpenCore
  rather than in the VM.
- **Automated input does not work.** The template attaches two keyboards and two tablets (XML
  `<input>` plus `-device usb-kbd` / `usb-tablet`), so `virsh send-key` and QEMU monitor mouse
  events land on the wrong device. Setup Assistant has to be driven by hand in VNC.
- **A finished install parked at Setup Assistant looks identical to a hang** on screen-hash and
  disk-growth metrics. Only instantaneous CPU separates them, idle versus spinning. Sample
  `/proc/<pid>/stat` fields 14 and 15 over an interval; `ps -o pcpu=` reports an average since
  process start and is useless here.
- **Zero disk growth during an install's second phase is normal.** That phase is CPU-bound.

## Storage placement

Guest images want storage that sustains writes. A USB-SATA enclosure can be a poor host: one
tested combination (Realtek RTL9201 bridge, budget cacheless SSD) sustained only about 25 MB/s of
writes against 386 MB/s reads, and threw UAS aborts under sustained write load that stalled I/O
for minutes at a time. If you place guests on storage like that, set `error_policy='stop'` and
`rerror='stop'` on the disks so libvirt pauses the VM on an I/O error instead of the guest taking
it mid-write.

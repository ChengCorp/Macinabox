# Macinabox

> **This is `ChengCorp/Macinabox`, a fork.** It diverges from `SpaceinvaderOne/Macinabox` (last
> upstream commit 2024-11-06) in three ways that matter:
>
> - **AMD hosts are supported.** Upstream shipped Intel CPU arguments unconditionally. This fork
>   detects the host vendor and applies a profile that boots macOS multi-core on AMD. The
>   configuration is non-obvious and is documented at [`docs/AMD-HOSTS.md`](docs/AMD-HOSTS.md).
>   **Read that before changing the CPU or bootloader handling.**
> - **Sequoia and Tahoe are selectable**, via a newer OpenCore image and a widened kernel range.
> - **Container updates actually reach existing installs.** Upstream copied its payload into
>   `/config` on first run only, so once a VM existed every later image shipped to nobody.
>
> Images are published to `ghcr.io/chengcorp/macinabox` by GitHub Actions on every push, not to
> Docker Hub: `docker pull ghcr.io/chengcorp/macinabox:latest`. You can also build locally with
> `docker build -t macinabox .`. Point the Unraid template at whichever you use.

Macinabox downloads and installs various macOS versions as a VM on your Unraid server. With this new version, there’s no need for additional helper scripts. It will fully automate the installation of the VM, create the XML file. It can get various details from your server to use in the VM creation such as seeing latest q35 available on your server and make sure VM uses that. All you need to do is choose the macOS version, specify the VM storage location, ISO location, and the container will handle the rest.
If you make any changes to the VM in the Unraid VM manager if you rerun the container it will fix any incorrect XML. Also if you have changed CPU core count it will check wether the VM should keep or remove the topology line to ensure the VM boots correctly.

On your server make sure to have notifications enabled and docker update notifications enabled. This will allow the container to send notifications as macinabox runs

## Usage

**If you have an older version of Macinbox on your Unraid server. You will need to remove the old macinabox**  

**Are you fully compliant with Apple’s EULA?**  
Set this to "Yes" if you are running on Apple hardware. This is the only way to be EULA compliant. If not, leave it as "No" and the container will exit.

**Operating System Version:**  
Choose the macOS version from the options below:
- Tahoe *(fork only)*
- Sequoia *(fork only)*
- Sonoma
- Ventura
- Monterey
- Big Sur
- Catalina
- Mojave
- High Sierra

Tahoe and Sequoia need `bootloader=opencore-osx-proxmox-vm.iso.gz`, which is the default resolved
for AMD hosts. See [`docs/AMD-HOSTS.md`](docs/AMD-HOSTS.md).

**Custom VM Name:**  
Use this if you want the VM name to differ from the OS version. Leave blank to use the OS name.

**Vdisk Type:**  
Set the vdisk type to either `raw` or `qcow2`.

**Vdisk Size:**  
Specify the desired size for the vdisk.

**Delete and Replace OpenCore:**  
Select "Yes" to delete your VM's OpenCore image and replace it with a fresh one, or "No" to keep the existing one.

**Default NIC Type:**  
The default is `virtio-net`. Change this to override the default NIC type for macOS versions that support it.
(note if you install a version of macOS that doesnt support virtio it will use an emulated intel nic)

**VM Images Location:**  
Set this to your VM storage location (e.g., Domains share).

**ISOs Share Location:**  
This is where macinabox will store the install media 

**Appdata Location:**  
Specify where you want macinabox to store its appdata.

Isos Share Location: You only need to change if your ISO images are not in the default location /mnt/user/isos
                  
appdata location:     If you change this you will need to do the same in the macinabox help user script


For a video guide on using the new macinabox please see here ........

# Single GPU Passthrough

**Note: This guide is configured only for my personal system, changes will be required if you want to do this for your system**

```sh
vim /etc/default/grub
```

Edit grub configuration.

| /etc/default/grub |
| ----- |
| `GRUB_CMDLINE_LINUX_DEFAULT="... intel_iommu=on iommu=pt ..."` |
| OR |
| `GRUB_CMDLINE_LINUX_DEFAULT="... amd_iommu=on iommu=pt ..."` |

```sh
grub-mkconfig -o /boot/grub/grub.cfg
```
```sh
sudo systemctl reboot
```
Make sure that your IOMMU groups are valid. \
Run the following script to view the IOMMU groups and attached devices. 

```sh
#!/bin/bash
shopt -s nullglob
for g in `find /sys/kernel/iommu_groups/* -maxdepth 0 -type d | sort -V`; do
    echo "IOMMU Group ${g##*/}:"
    for d in $g/devices/*; do
        echo -e "\t$(lspci -nns ${d##*/})"
    done;
done;
```
### **Install required tools**
<details>
  <summary><b>Gentoo Linux</b></summary>
  RECOMMENDED USE FLAGS: app-emulation/virt-manager gtk<br>
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; app-emulation/qemu spice usb usbredir pulseaudio
                         
  ```sh
  emerge -av qemu virt-manager libvirt ebtables dnsmasq
  ```
</details>

<details>
  <summary><b>Arch Linux</b></summary>

  ```sh
  pacman -S qemu libvirt edk2-ovmf virt-manager dnsmasq ebtables
  ```
</details>

<details>
  <summary><b>Fedora</b></summary>

  ```sh
  dnf install @virtualization
  ```
</details>

<details>
  <summary><b>Ubuntu</b></summary>

  ```sh
  apt install qemu-kvm qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager ovmf
  ```
</details>

```
sudo vim /etc/libvirt/libvirtd.conf
```
add or uncommend the # off the follow lines:

```
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
```

### **Enable required services**
<details>
  <summary><b>SystemD</b></summary>

  ```sh
  systemctl enable --now libvirtd
  ```
</details>

<details>
  <summary><b>OpenRC</b></summary>

  ```sh
  rc-update add libvirtd default
  rc-service libvirtd start
  ```
</details>

Sometimes, you might need to start default network manually.

```sh
virsh net-start default
virsh net-autostart default
```

### **Setup Guest OS**
***NOTE: You should replace win10 with your VM's name where applicable*** \
You should add your user to ***libvirt*** group to be able to run VM without root. And, ***input*** and ***kvm*** group for passing input devices.
```sh
usermod -aG kvm,input,libvirt username
```
### **Copy hooks folder**
```sh
sudo cp -r hooks/ /etc/libvirt/
```

### **Copy patch.rom**
**Note : My patch.rom is only for Zotac GTX 1660 Ti 6 GB. To make one for your gpu, follow [this guide by Risingprism](https://gitlab.com/risingprismtv/single-gpu-passthrough/-/wikis/home)**
```
sudo mkdir /usr/share/vgabios
```
place the rom in above directory with
```
sudo cp patch.rom /usr/share/vgabios
```

```
sudo chmod -R 660 /usr/share/vgabios/patch.rom
```

### Change ``` s:s ``` to your ```username:username```
```
sudo chown s:s /usr/share/vgabios/patch.rom
```
### Hooks folder should look like this

```tree /etc/libvirt/hooks```

```/etc/libvirt/hooks
|-- kvm.conf
|-- qemu
`-- qemu.d
    `-- win10
        |-- prepare
        |   `-- begin
        |       |-- isolstart.sh
        |       `-- start.sh
        `-- release
            `-- end
                |-- isocpurevert.sh
                `-- revert.sh

6 directories, 6 files 
```
### Place win10.qcow2 file in /var/lib/libvirt/images/
**Note : If you don't have the file, just create a win10 virtual machine without GPU passthrough and delete the vm while keeping the storage (qcow2) file** 

```
sudo cp win10.qcow2  /var/lib/libvirt/images/
```
### Create win10 vm using the xml
```
sudo virsh define /path/to/win10.xml
```

### Open virt-manager and launch win10 vm

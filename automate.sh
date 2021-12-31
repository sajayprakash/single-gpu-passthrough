#!/bin/bash

echo 'unix_sock_group = "libvirt"' | sudo tee -a /etc/libvirt/libvirtd.conf
echo 'unix_sock_rw_perms = "0770"' | sudo tee -a /etc/libvirt/libvirtd.conf


echo 'user = "s"' | sudo tee -a /etc/libvirt/libvirtd.conf
echo 'group = "s"' | sudo tee -a /etc/libvirt/libvirtd.conf

sudo systemctl restart libvirtd
systemctl enable --now libvirtd

sudo virsh net-start default
sudo virsh net-autostart default

usermod -aG kvm,input,libvirt s

sudo mkdir /usr/share/vgabios
sudo cp -r $HOME/single-gpu-passthrough/hooks/ /etc/libvirt/
sudo cp $HOME/single-gpu-passthrough/patch.rom /usr/share/vgabios
sudo chmod -R 660 /usr/share/vgabios/patch.rom
sudo chown s:s /usr/share/vgabios/patch.rom

sudo cp /mnt/hdd2/VM/win10.qcow2  /var/lib/libvirt/images/
sudo chown s:s /var/lib/libvirt/images/win10.qcow2


sudo virsh define $HOME/single-gpu-passthrough/win10.xml

echo "SCRIPT COMPLETED!"

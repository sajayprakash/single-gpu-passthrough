#!/bin/bash

# Debugging
set -x

# load defined variables
source "/etc/libvirt/hooks/kvm.conf"

# Stop display manager
systemctl stop lightdm.service

## Uncomment the following line if you use GDM
#killall gdm-x-session

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI-Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid a Race condition by waiting 10 seconds. This can be calibrated to be shorter or longer if required for your system
sleep 10

# Unload Nvidia
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r drm_kms_helper
modprobe -r nvidia
modprobe -r i2c_nvidia_gpu
modprobe -r drm
modprobe -r nvidia_uvm

# Unbind the GPU from display driver
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO
virsh nodedev-detach $VIRSH_GPU_USB

# Load VFIO Kernel Module  
modprobe vfio-pci  
modprobe vfio 
modprobe vfio_iommu_type1

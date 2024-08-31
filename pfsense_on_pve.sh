#!/bin/bash
# Script to create pfSense VM on Proxmox

# Prompt for input values
read -p "Enter the VM ID: " VM_ID
read -p "Enter the ISO storage location: " ISO_STORAGE
read -p "Enter the ISO image filename: " ISO_IMAGE
read -p "Enter the storage location for the primary disk: " VM_STORAGE
read -p "Enter the disk size (e.g., 100G): " DISK_SIZE
read -p "Enter the number of CPU cores: " CPU_CORES
read -p "Enter the RAM size in MB: " RAM_SIZE
read -p "Enter the bridge name for the WAN interface: " WAN_BRIDGE
read -p "Enter the bridge name for the LAN interface: " LAN_BRIDGE
read -p "Enter the bridge name for the sync interface: " SYNC_BRIDGE

# Create the VM
qm create $VM_ID --name "pfSense-HA" --memory $RAM_SIZE --cores $CPU_CORES --net0 virtio,bridge=$WAN_BRIDGE --cdrom $ISO_STORAGE:iso/$ISO_IMAGE
qm set $VM_ID --scsihw virtio-scsi-pci --scsi0 $VM_STORAGE:$DISK_SIZE,discard=on
qm set $VM_ID --boot order=ide2,scsi0
qm set $VM_ID --net1 virtio,bridge=$LAN_BRIDGE
qm set $VM_ID --net2 virtio,bridge=$SYNC_BRIDGE
qm set $VM_ID --machine q35
qm set $VM_ID --cpu host
qm set $VM_ID --kvm 1
qm set $VM_ID --agent enabled=1
qm set $VM_ID --scsi0 $VM_STORAGE:$DISK_SIZE,iothread=1,aio=io_uring,cache=writeback
qm set $VM_ID --scsi0 $VM_STORAGE:$DISK_SIZE,iothread=1,backup=1

# Start the VM
qm start $VM_ID

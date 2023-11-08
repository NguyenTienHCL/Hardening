#!/bin/bash

# Check if you are running as root
echo "Check if you are running as root:"
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Check kernel version
echo "Check kernel version:"
uname -msr

# Update the system
echo "Update ther system"
yum update -y


# Install required packages
echo "Enable the Elrepo repository"
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

# Add the new Elrepo repository
echo "Add the new Elrepo repository"
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm

# List available kernel versions
echo "List available kernel versions"
yum list available --disablerepo'*' --enablerepo=elrepo-kernel

# Install the latest kernel version
echo "Install the latest kernel version"
echo "Install stable long-term support release"
yum --enablerepo=elrepo-kernel install kernel-lt -y

# Edit the GRUB configuration
GRUB_CONFIG="/etc/default/grub"
sed -i 's/GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' "$GRUB_CONFIG"

# Recreate the kernel configuration
grub2-mkconfig -o /boot/grub2/grub.cfg

# Reboot the system to use the latest kernel
echo "Reboot the system to use the latest kernel"
reboot

# After reboot, verify the new kernel version
uname -r


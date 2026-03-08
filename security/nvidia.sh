#!/bin/env bash
# The script is made just to install nvidia driver package.

case $1 in
	"-i"|"--install")
    	dpkg --add-architecture i386 && apt update
    	apt install linux-headers-amd64 -y
    	apt install nvidia-kernel-dkms nvidia-driver firmware-misc-nonfree nvidia-driver-libs:i386 -y
    	echo "options nvidia-drm modeset=1" | tee -a /etc/modprobe.d/nvidia-options.conf
    	#echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" >> /etc/modprobe.d/nvidia-options.conf
    	echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' | tee /etc/default/grub.d/nvidia-modeset.cfg
    	update-grub
    	systemctl enable nvidia-suspend.service nvidia-hibernate nvidia-resume
    	echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' | tee -a /etc/modprobe.d/nvidia-power-management.conf
        systemctl reboot
	    ;;
	"-u"|"--uninstall"|"-r")                 
        apt --autoremove purge '*nvidia*' '*nvidia*:i386' '*cuda*' '*cuda*:i386'
        rm -rf /etc/default/grub.d/nvidia-modeset.cfg &&  update-grub
	    # apt install --reinstall xserver-xorg-core xserver-xorg-video-nouveau
	    systemctl reboot
	    #X -configure
	    ;;
	*)
	    echo invalid option.
	    ;;
esac

#!/bin/env bash
# The script is made just to install nvidia driver package.


case $1 in
	"-i"|"--install")
    	dpkg --add-architecture i386 && apt update
    	apt install linux-headers-amd64 -y
    	apt install nvidia-kernel-dkms nvidia-driver firmware-misc-nonfree nvidia-driver-libs:i386 -y
    	echo "options nvidia-drm modeset=1" | tee -a /etc/modprobe.d/nvidia-options.conf
    	#echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" >> /etc/modprobe.d/nvidia-options.conf
    	echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' | tee -a /etc/default/grub.d/nvidia-modeset.cfg
    	update-grub
    	systemctl enable nvidia-suspend.service
    	systemctl enable nvidia-hibernate.service
    	systemctl enable nvidia-resume.service
    	echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' | tee -a /etc/modprobe.d/nvidia-power-management.conf
        systemctl reboot
	    ;;
	"-u"|"--uninstall"|"-r")                 
	    apt purge "*nvidia*"
        rm -rf /etc/default/grub.d/nvidia-modeset.cfg &&  update-grub
	    # systemctl reboot
	    # apt install --reinstall xserver-xorg-core xserver-xorg-video-nouveau
	    #X -configure
	    ;;
	*)
	    echo invalid option.
	    ;;
esac

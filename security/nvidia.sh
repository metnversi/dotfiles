#!/bin/env bash

case $1 in
	"-i"|"--install")
    	sudo dpkg --add-architecture i386 && sudo apt update
    	sudo apt install linux-headers-amd64 -y
    	sudo apt install nvidia-kernel-dkms nvidia-driver firmware-misc-nonfree nvidia-driver-libs:i386 -y
    	echo "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia-options.conf
    	#echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" >> /etc/modprobe.d/nvidia-options.conf
    	echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX nvidia-drm.modeset=1"' | sudo tee -a /etc/default/grub.d/nvidia-modeset.cfg
    	sudo update-grub
    	sudo systemctl enable nvidia-suspend.service
    	sudo systemctl enable nvidia-hibernate.service
    	sudo systemctl enable nvidia-resume.service
    	echo 'options nvidia NVreg_PreserveVideoMemoryAllocations=1' | sudo tee -a /etc/modprobe.d/nvidia-power-management.conf
        sudo systemctl reboot
	    ;;
	"-u"|"--uninstall"|"-r")                 
	    sudo apt purge "*nvidia*"
        sudo rm -rf /etc/default/grub.d/nvidia-modeset.cfg && sudo update-grub
	    #sudo systemctl reboot
	    #sudo apt install --reinstall xserver-xorg-core xserver-xorg-video-nouveau
	    #X -configure
	    ;;
	*)
	    echo invalid option.
	    ;;
 esac

#!/bin/bash

###########################
#Usage 
###########################
#This script is intended for post install on a xubuntu 13.10 system on virtual box !
:<<'USAGE'
sudo apt-get install git
git clone https://github.com/gargamel007/LinuxPostInstallScripts.git Code/LinuxPostInstallScripts
sudo bash Code/LinuxPostInstallScripts/VboxXubuntuSaucy.sh
USAGE

###########################
#Configuration
###########################
USERNAME="gargamel"


###########################
#Utilities & Tools
###########################
setupTools() {
  echo "Install Tools"
  #Sublime text in now available in version 3 but still use version 2
  add-apt-repository -y ppa:webupd8team/sublime-text-2
  apt-get update
  apt-get install -y sublime-text
  #tree lists contents of a directory
  apt-get install -y tree terminator vim less screen git terminator htop git
}

###########################
#Upgrade system
###########################
upgradeSystem() {
  echo "Upgrade system"
  apt-get dist-upgrade -y
}

###########################
#Virtual Box stuff
###########################
setupVboxTools() {
  echo "Installing Virtual Box Stuff"
  apt-get -y install dkms linux-headers-generic linux-headers-$(uname -r)
  echo "###########################################"
  echo "Mount Additions CD-ROM and press any key"
  read unused
  cd /media/$USERNAME/VBOX*
  ./VBoxLinuxAdditions.run
  cd /home/$USERNAME
  #Mount Shared folders
  adduser $USERNAME vboxsf
  #setup you shared folder for auto mount and make permanent.
  #and just reboot : folder will be in /media/sf_SHARENAME
}


###########################
#MAIN SECTION
###########################
setupTools
upgradeSystem
setupVboxTools

echo "###########################################"
echo "#####	Setup Completed	  ##########"
echo " "
echo "You can reboot your system now !"

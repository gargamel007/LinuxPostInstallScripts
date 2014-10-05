#!/bin/bash

###########################
#Doc & Usage 
###########################
#This script is intended for post install on a xubuntu 13.10 system on virtual box !
:<<'USAGE'
Select a fast mirror using GUI tools
sudo apt-get install git
git clone https://github.com/gargamel007/LinuxPostInstallScripts.git Code/LinuxPostInstallScripts
sudo bash Code/LinuxPostInstallScripts/VboxXubuntu1404.sh
USAGE



###########################
#Configuration
###########################
USERNAME="gargamel"
SUDO_TIMEOUT=60

###########################
#Utilities & Tools
###########################
setupTools() {
  echo "Install Tools"
  #Sublime text in now available in version 3 lets try it
  add-apt-repository -y ppa:webupd8team/sublime-text-3
  apt-get update
  apt-get install -y sublime-text-installer
  #tree lists contents of a directory
  #ncdu can find which folder is getting too big
  apt-get install -y -qq terminator tree vim less screen git htop mosh sshfs ncdu tmux rubygems
  gem install tmuxinator
}

###########################
#System Tweaking
###########################
systemTweak() {
  echo "System Tweaking"
  #Decrease swapiness
  if ! grep -q swapiness /etc/sysctl.conf 
    then
    "# Decrease swap usage to a more reasonable level" >> /etc/sysctl.conf
    "vm.swappiness=5" >> /etc/sysctl.conf
  fi
  #Add noatime to decrease ssd usage
  if ! grep -q noatime /etc/fstab 
    then sed -i "s/errors/noatime,errors/g" /etc/fstab
  fi
}



###########################
#Extend sudo timeout
###########################
changeSudoTimeout() {
  echo "Extend sudo timeout to $SUDO_TIMEOUT"
  cp /etc/sudoers /tmp/sudoers.new
    if ! grep -q passwd_timeout /tmp/sudoers.new 
    then
    sudo sed -i "s/env_reset/env_reset,passwd_timeout=$SUDO_TIMEOUT/g" /tmp/sudoers.new
  fi
  cp /tmp/sudoers.new /etc/sudoers
  rm /tmp/sudoers.new
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
  echo "Mount Additions CD-ROM open folder and press any key"
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
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
fi

changeSudoTimeout
setupTools
systemTweak
upgradeSystem
setupVboxTools

echo "###########################################"
echo "#####	Setup Completed	  ##########"
echo " "
echo "You can reboot your system now !"
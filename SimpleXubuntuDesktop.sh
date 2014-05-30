#!/bin/bash

###########################
#Doc & Usage 
###########################
#This script is intended for post install on a xubuntu 14.04 system on a simple laptop
:<<'USAGE'
sudo apt-get -qq update && apt-get -y -qq install git
git clone https://github.com/gargamel007/LinuxPostInstallScripts.git Code/LinuxPostInstallScripts
sudo bash Code/LinuxPostInstallScripts/SimpleXubuntuDesktop.sh
USAGE

###########################
#Configuration
###########################
USERNAME="gargamel"
BASEDIR=$(dirname $0)



###########################
#Main
###########################
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
fi


#Install Tools
echo "#############################"
echo "UPGRADE  && INSTAL BASE TOOLS"
apt-get -qq update && apt-get -qq -y upgrade
#tree lists contents of a directory
apt-get install -y -qq tree vim less screen git htop mosh openssh-server terminator sshfs gksu leafpad synaptic gdebi linux-firmware-nonfree gparted
apt-get install -y -qq vlc aptitude synaptic gdebi-core gnome-system-monitor xubuntu-restricted-extras libavcodec-extra ttf-mscorefonts-installer non-free-codecs
#speedup app startup time
apt-get install -y -qq preload zram-config
#Optionnal : shotwell (photo organizer), clementine (music player)

#Setup a proper ssh server
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

##Fix blank screen on resume Bug in Xubuntu :(
#sudo add-apt-repository ppa:xubuntu-dev/ppa
#sudo apt-get update && sudo apt-get install xfce4-power-manager light-locker-settings

#For laptops
add-apt-repository ppa:linrunner/tlp
apt-get update
apt-get install tlp tlp-rdw

tee -a /etc/sysctl.conf 1>/dev/null <<END
# Decrease swap usage to a reasonable level
vm.swappiness=5
# Improve cache management
vm.vfs_cache_pressure=50
END

wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
gdebi google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

echo "Once completed press any key"
read a_unused

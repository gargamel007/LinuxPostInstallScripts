#!/bin/bash

###########################
#Doc & Usage 
###########################
#This script is intended for post install on a Ub Server 14.04 !
:<<'USAGE'
sudo apt-get -qq update && sudo apt-get -y -qq upgrade && sudo apt-get -y -qq install git
git clone https://github.com/gargamel007/LinuxPostInstallScripts.git Code/LinuxPostInstallScripts
sudo bash Code/LinuxPostInstallScripts/VboxUbServerBuildEnv.sh
USAGE

###########################
#Configuration
###########################
BASEDIR=$(dirname $0)


###########################
#Main
###########################
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
fi
#To prevent dialogs
export DEBIAN_FRONTEND=noninteractive
#Show all commands
set -x

#Fix locale issue
/usr/share/locales/install-language-pack fr_FR
/usr/share/locales/install-language-pack en_US
locale-gen --purge fr_FR.UTF-8 en_US.UTF-8
if [ ! -f /tmp/is_reset_locale ]; then dpkg-reconfigure locales; fi
touch /tmp/is_reset_locale
update-locale


#Install Tools
echo "#############################"
echo "UPGRADE  && INSTAL BASE TOOLS"
apt-get -qq update && apt-get -qq -y upgrade
INSTPKG="dialog tree vim less screen git htop software-properties-common mosh rsync ncdu"
#Perl is needed for rename command
INSTPKG+=" perl sudo locate toilet"
apt-get install -y -qq $INSTPKG



#Tweak vim 
sed -i "s/\"syntax on/syntax on/g" /etc/vim/vimrc


#Cleanup
set +x
unset DEBIAN_FRONTEND
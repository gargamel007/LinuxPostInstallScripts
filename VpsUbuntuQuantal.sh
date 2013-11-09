#!/bin/bash

###########################
#Doc & Usage 
###########################
#This script is intended for post install on a xubuntu 13.10 system on virtual box !
:<<'USAGE'
sudo apt-get -qq update && apt-get -y -qq install git
git clone https://github.com/gargamel007/LinuxPostInstallScripts.git Code/LinuxPostInstallScripts
sudo bash Code/LinuxPostInstallScripts/VpsUbuntuQuantal.sh
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


adduser $USERNAME
adduser $USERNAME sudo

#Setup a proper ssh server
sed -i "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

#Install Tools
echo "#################"
echo "UPGRADE INSTAL BASE TOOLS"
apt-get -qq update && apt-get -qq -y upgrade
#tree lists contents of a directory
apt-get install -y -qq dialog tree vim less screen git htop software-properties-common


#Install tvmanmer && Subliminal
echo "#################"
echo "INSTALLING TV TOOLS"
apt-get -y -qq install python-bs4 python-requests python-html5lib python-lxml python-dev libxml2-dev  libxslt-dev git-core python-pip git-core python-pip
pip install -q subliminal tvnamer
su $USERNAME -c "tvnamer --save=/tmp/mytvnamerconfig.json" #Edit file
su $USERNAME -c "mv /tmp/mytvnamerconfig.json ~/.tvnamer.json" #Place in Home dir !

## Install bittorent client :
echo "#################"
echo "INSTALLING DELUGE"
add-apt-repository -y ppa:deluge-team/ppa
apt-get install -y -qq deluged deluge-web
adduser --disabled-password --system --home /var/lib/deluge --gecos "$USERNAME Deluge Server" --group deluge
touch /var/log/deluged.log
touch /var/log/deluge-web.log
chown deluge:deluge /var/log/deluge*
adduser $USERNAME deluge
mkdir /var/lib/deluge/incoming
chown deluge:deluge /var/lib/deluge/incoming
openssl req -new -x509 -nodes -out /var/lib/deluge/ssl/deluge.cert.pem -keyout /var/lib/deluge/ssl/deluge.key.pem
chown deluge:deluge *


tee /etc/default/deluge-daemon 1>/dev/null <<END
# Configuration for /etc/init.d/deluge-daemon
# The init.d script will only run if this variable non-empty.
DELUGED_USER="deluge"
# Should we run at startup?
RUN_AT_STARTUP="YES"
END

mv $BASEDIR/UtilScripts/deluge-deamon /etc/init.d/deluge-daemon
chmod 755 /etc/init.d/deluge-daemon
update-rc.d deluge-daemon defaults
/etc/init.d/deluge-daemon start

ln -s /var/lib/deluge/ /home/$USERNAME/deluge_folder
mkdir /home/$USERNAME/ready
chown -R $USERNAME:$USERNAME /home/$USERNAME/


echo "Please log in to Deluge and configure password and ssl - default port is 9092"
echo "Once completed press any key"
read a_unused

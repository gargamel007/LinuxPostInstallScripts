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

#Fix locale issue
locale-gen en_US.UTF-8
locale-gen fr_FR.UTF-8
update-locale

#Install Tools
echo "#############################"
echo "UPGRADE  && INSTAL BASE TOOLS"
apt-get -qq update && apt-get -qq -y upgrade
#tree lists contents of a directory
apt-get install -y -qq dialog tree vim less screen git htop software-properties-common mosh


#Install tvmanmer && Subliminal
echo "#################"
echo "INSTALLING TV TOOLS"
apt-get -y -qq install python-bs4 python-requests python-html5lib python-lxml python-dev libxml2-dev  libxslt-dev git-core python-pip git-core python-pip
pip install -q subliminal tvnamer
su $USERNAME -c "tvnamer --save=/tmp/mytvnamerconfig.json" #Edit file
su $USERNAME -c "mv /tmp/mytvnamerconfig.json ~/.tvnamer.json" #Place in Home dir !
mkdir -p /home/$USERNAME/.config

#Install vsftpd ftp server with SSL
echo "#################"
echo "INSTALLING SECURED FTP SERVER"
###@TODO remove this section as the FTPS Server is not working... sftp is sufficient anyways
apt-get install vsftpd
sed -i "s/#chroot_local_user=YES/chroot_local_user=YES/g" /etc/vsftpd.conf

mkdir -p /etc/vsftpd
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem

tee -a /etc/vsftpd.conf 1>/dev/null <<END

##################################
# Custom Configuration for SSL access
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=NO
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
rsa_cert_file=/etc/vsftpd/vsftpd.pem
# Filezilla uses port 21 if you don't set any port
# in Servertype "FTPES - FTP over explicit TLS/SSL"
# Port 990 is the default used for FTPS protocol.
# Uncomment it if you want/have to use port 990.
# listen_port=990
END


service vsftpd restart

## Install bittorent client :
echo "#################"
echo "INSTALLING DELUGE"
add-apt-repository -y ppa:deluge-team/ppa
apt-get install -y -qq deluged deluge-web deluge-console
adduser --disabled-password --system --home /var/lib/deluge --gecos "$USERNAME Deluge Server" --group deluge
touch /var/log/deluged.log
touch /var/log/deluge-web.log
chown deluge:deluge /var/log/deluge*
adduser $USERNAME deluge
#Create destination directories
mkdir -p /var/lib/deluge/incoming /var/lib/deluge/completed
mkdir -p /var/lib/deluge/ssl
openssl req -new -x509 -nodes -out /var/lib/deluge/ssl/daemon.cert -keyout /var/lib/deluge/ssl/deamon.pkey
chown -R deluge:deluge /var/lib/deluge


tee /etc/default/deluge-daemon 1>/dev/null <<END
# Configuration for /etc/init.d/deluge-daemon
# The init.d script will only run if this variable non-empty.
DELUGED_USER="deluge"
# Should we run at startup?
RUN_AT_STARTUP="YES"
END

#Remove Default script created by Ubuntu
service deluged stop
sleep 4
update-rc.d -f deluged remove
rm /etc/init.d/deluged

mv $BASEDIR/UtilScripts/deluge-deamon /etc/init.d/deluge-daemon
chmod 755 /etc/init.d/deluge-daemon
update-rc.d deluge-daemon defaults
/etc/init.d/deluge-daemon start
sleep 6
#reconfigure deluged 
deluge-console -c /var/lib/deluge "config -s move_completed true"
deluge-console -c /var/lib/deluge "config -s move_completed_path /var/lib/deluge/completed"
deluge-console -c /var/lib/deluge "config -s download_location /var/lib/deluge/incoming"
deluge-console -c /var/lib/deluge "config -s max_connections_global 800"
deluge-console -c /var/lib/deluge "config -s max_upload_slots_global 2"
deluge-console -c /var/lib/deluge "config -s max_half_open_connections 150"
deluge-console -c /var/lib/deluge "config -s max_connections_per_second 60"
deluge-console -c /var/lib/deluge "config -s max_active_downloading 4"
deluge-console -c /var/lib/deluge "config -s max_active_seeding 1"
deluge-console -c /var/lib/deluge "config -s stop_seed_at_ratio true"
deluge-console -c /var/lib/deluge "config -s stop_seed_ratio 1.1"
deluge-console -c /var/lib/deluge "config -s max_upload_slots_global 2"

ln -s /var/lib/deluge/ /home/$USERNAME/deluge_folder
mkdir -p /home/$USERNAME/ready /home/$USERNAME/cleaning
chown -R $USERNAME:$USERNAME /home/$USERNAME/

echo "Please log in to Deluge and configure password and ssl"
echo "use https default port is 9092 - default pass is deluge"
echo "Once completed press any key"
read a_unused

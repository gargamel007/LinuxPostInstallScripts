#!/bin/bash

###########################
#Doc & Usage
###########################
#This script is intended for post install on a xubuntu 13.10 system on virtual box !
:<<'USAGE'
Select a fast mirror using GUI tools
sudo apt-get install git
mkdir ~/Code
git clone https://github.com/gargamel007/LinuxPostInstallScripts.git Code/LinuxPostInstallScripts
sudo bash Code/LinuxPostInstallScripts/VboxXubuntu1510.sh
USAGE



###########################
#Configuration
###########################
USERNAME="aditye"
SUDO_TIMEOUT=60

###########################
#Utilities & Tools
###########################
setupTools() {
  echo "Install Tools"
  apt-get update -qq
  #tree lists contents of a directory
  #typecatcher can donwload some nice fonts
  #ncdu can find which folder is getting too big
  apt-get install -y -qq terminator tree vim less git htop mosh sshfs ncdu tmux typecatcher
  apt-get install -y -qq aptitude gparted unetbootin
}

setupZsh() {
  apt-get install -y -qq zsh  
  #Install Oh My Zsh
  wget --no-check-certificate http://install.ohmyz.sh -O - | sh
  #it installs in user home dir so 2 lines below are not needed
  #cp -R /root/.oh-my-zsh/ /home/$USERNAME/
  #cp /root/.zsh* /home/$USERNAME/
  chown -R $USERNAME:$USERNAME /home/$USERNAME/.*
  local ZSHPATH=`which zsh`
  su $USERNAME -c "chsh -s $ZSHPATH"
}

setupDocker() {
  echo "Install Docker"
  wget -qO- https://get.docker.io/gpg | apt-key add -
  echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  apt-get install -y -qq lxc-docker
}

###########################
#System Tweaking
###########################
systemTweak() {
  echo "System Tweaking"
  #Decrease swapiness
  if ! grep -q swapiness /etc/sysctl.conf
    then
    echo "# Decrease swap usage to a more reasonable level" >> /etc/sysctl.conf
    echo "vm.swappiness=5" >> /etc/sysctl.conf
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
  apt-get dist-upgrade -y -qq
}

###########################
#Virtual Box stuff
###########################
setupVboxTools() {
  echo "Installing Virtual Box Stuff"
  apt-get -y -qq install dkms linux-headers-generic linux-headers-$(uname -r)
  echo "###########################################"
  echo "Mount Additions CD-ROM open folder and press ENTER"
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
#SSH Config
###########################
sshConfig() {
  echo "Generate SSH keys ! DO NOT USE PASSPHRASE"
  su $USERNAME -c "ssh-keygen -t dsa -f /home/$USERNAME/.ssh/id_dsa"
  su $USERNAME -c "ssh-keygen -t rsa"
  su $USERNAME -c "cat /home/$USERNAME/.ssh/id_rsa.pub >> /home/$USERNAME/.ssh/authorized_keys"
}

###########################
#Fonts Configuration
###########################
fontConfig() {
  #make cursor blink in xfce-4 terminal
  sed -i "s/MiscCursorBlinks=FALSE/MiscCursorBlinks=TRUE/g" /home/$USERNAME/.config/xfce4/terminal/terminalrc
  #Underline does not goes well with vim cursoline :(
  #sed -i "s/MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK/MiscCursorShape=TERMINAL_CURSOR_SHAPE_UNDERLINE/g" /home/$USERNAME/.config/xfce4/terminal/terminalrc
  wget https://github.com/Lokaltog/powerline-fonts/raw/master/Inconsolata-g/fonts.dir
  wget https://github.com/Lokaltog/powerline-fonts/raw/master/Inconsolata-g/Inconsolata-g%20for%20Powerline.otf
  wget https://github.com/Lokaltog/powerline-fonts/raw/master/Inconsolata-g/fonts.scale
  mkdir -p /home/$USERNAME/.fonts/Powerline/
  mv 'Inconsolata-g for Powerline.otf' /home/$USERNAME/.fonts/Powerline/
  mv 'fonts.dir' /home/$USERNAME/.fonts/Powerline/
  mv 'fonts.scale' /home/$USERNAME/.fonts/Powerline/
  chown -R $USERNAME:$USERNAME /home/$USERNAME/.fonts
  su $USERNAME -c "fc-cache -vf ~/.fonts/"
}

###########################
# Tools Config
###########################
toolsConfig() {
  su $USERNAME -c "git config --global color.ui true"
  su $USERNAME -c "git config --global credential.helper cache"
  su $USERNAME -c "git config --global credential.helper \"cache --timeout=7200\""
}

##########################
# Install Arduino Tools 
##########################
installJava() {
    add-apt-repository ppa:webupd8team/java
    apt-get update
    apt-get install oracle-java8-installer

}

setupArduinoTools() {
    usermod -a -G tty $USERNAME
    usermod -a -G dialout $USERNAME

}



###########################
#MAIN SECTION
###########################
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user" 2>&1
  exit 1
fi

#changeSudoTimeout
#setupTools
#setupZsh
#setupDocker
#systemTweak
#upgradeSystem
#setupVboxTools
sshConfig
fontConfig
installJava
setupArduinoTools
#toolsConfig

echo "###########################################"
echo "#####	Setup Completed	  ##########"
echo " "
echo "You can reboot your system now ! do not forget to change terminal fonts and colors"

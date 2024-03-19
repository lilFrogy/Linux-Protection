#!/bin/bash

# Ubuntu Security Script

if [[ $EUID -ne 0 ]]
then
  echo "You must be root to run this script."
  exit 1
fi

echo "Firewall"
# Firewall
sudo apt-get install -y ufw
sudo ufw enable

echo "Updates"
# Updates
#sudo apt-get -y upgrade
#sudo apt-get -y update

echo "Lock Out Root User"
# Lock Out Root User
sudo passwd -l root

echo "Disable Guest Account"
# Disable Guest Account
echo "allow-guest=false" >> /etc/lightdm/lightdm.conf

echo " Configure Password Aging Controls"
# Configure Password Aging Controls
sudo sed -i '/^PASS_MAX_DAYS/ c\PASS_MAX_DAYS   90' /etc/login.defs
sudo sed -i '/^PASS_MIN_DAYS/ c\PASS_MIN_DAYS   10'  /etc/login.defs
sudo sed -i '/^PASS_WARN_AGE/ c\PASS_WARN_AGE   7' /etc/login.defs

echo "Password Authentication"
# Password Authentication
sudo sed -i '1 s/^/auth optional pam_tally.so deny=5 unlock_time=900 onerr=fail audit even_deny_root_account silent\n/' /etc/pam.d/common-auth

echo "Force Strong Passwords"
# Force Strong Passwords
sudo apt-get -y install libpam-cracklib
sudo sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=3 reject_username minclass=3 maxrepeat=2 dcredit=1 ucredit=1 lcredit=1 ocredit=1\n/' /etc/pam.d/common-password

 find / -name '*.mp3' -type f -delete
    find / -name '*.mov' -type f -delete
    find / -name '*.mp4' -type f -delete
    find / -name '*.avi' -type f -delete
    find / -name '*.mpg' -type f -delete
    find / -name '*.mpeg' -type f -delete
    find / -name '*.flac' -type f -delete
    find / -name '*.m4a' -type f -delete
    find / -name '*.flv' -type f -delete
    find / -name '*.ogg' -type f -delete
    find /home -name '*.gif' -type f -delete
    find /home -name '*.png' -type f -delete
    find /home -name '*.jpg' -type f -delete
    find /home -name '*.jpeg' -type f -delete

echo "Malware removal"
# Malware
sudo apt-get -y purge hydra*
sudo apt-get -y purge john*
sudo apt-get -y purge nikto*
sudo apt-get -y purge netcat*
sudo apt-get -y purge transmisson*
sudo apt-get -y purge wireshark*

echo "Defult Browser & Update"
#Defult Browser & Update
sudo update-alternatives --config x-www-browser
sudo apt-get update && sudo apt-get install firefox

echo "RootKit Scan & Removal"
#RootKit Scan & Removal
sudo apt-get install chkrootkit
sudo chkroot
sudo apt-get purge chkrootkit -y 

echo "Fork addons"
# Fork addons
echo "Enable check for updates every day in the GUI"
sudo apt-get install i3 vim 
sudo apt-get remove gnome-mahjongg gnome-mines gnome-sudoku account-plugin-facebook account-plugin-flickr account-plugin-jabber account-plugin-salut account-plugin-twitter account-plugin-windows-live account-plugin-yahoo

echo " Media removal"
# Media removal 
echo "This will print all media to file media.txt"
echo $(ls -R *.mp3 *.mp4 *.png *.jpeg *.jpg *.wav *.flac *.mov)
ls -R *.mp3 *.mp4 *.png *.jpeg *.jpg *.wav *.flac *.mov > /home/`whoami`/media.txt
# Packge listing 
sudo dpkg -l > /home/`whoami`/packages

sudo apt-get install htop -y
echo "you can run htop"

echo "MySQL"
# MySQL
echo -n "MySQL [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]
then
  sudo apt-get -y install mysql-server
  # Disable remote access
  sudo sed -i '/bind-address/ c\bind-address = 127.0.0.1' /etc/mysql/my.cnf
  sudo service mysql restart
else
  sudo apt-get -y purge mysql*
fi

echo "OpenSSH server"
# OpenSSH Server
echo -n "OpenSSH Server [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]
then
  sudo apt-get -y install openssh-server
  # Disable root login
  sudo sed -i '/^PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config
  sudo service ssh restart
else
  sudo apt-get -y purge openssh-server*
fi

echo "VSFTP"
# VSFTPD
echo -n "VSFTP [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]
then
  sudo apt-get -y install vsftpd
  # Disable anonymous uploads
  sudo sed -i '/^anon_upload_enable/ c\anon_upload_enable no' /etc/vsftpd.conf
  sudo sed -i '/^anonymous_enable/ c\anonymous_enable=NO' /etc/vsftpd.conf
  # FTP user directories use chroot
  sudo sed -i '/^chroot_local_user/ c\chroot_local_user=YES' /etc/vsftpd.conf
  sudo service vsftpd restart
else
  sudo apt-get -y purge vsftpd*
fi


#!/bin/bash
done

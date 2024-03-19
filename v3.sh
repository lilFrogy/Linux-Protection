#!/bin/bash

# Ubuntu Security Script | my personal fav version!

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "You must be root to run this script."
    exit 1
fi

# Define some variables
FIREWALL="ufw"
MYSQL_SERVER="mysql-server"
OPENSSH_SERVER="openssh-server"
VSFTPD="vsftpd"

# Install firewall
if ! dpkg -s $FIREWALL >/dev/null 2>&1; then
    apt-get -y install $FIREWALL
    ufw enable
fi

# Updates
apt-get -y upgrade
apt-get -y update

# Lock Out Root User
passwd -l root

# Disable Guest Account
if [ -f /etc/lightdm/lightdm.conf ]; then
    echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
fi

# Configure Password Aging Controls
if [ -f /etc/login.defs ]; then
    debconf-set-selections <<< "login/pass_max_days 90"
    debconf-set-selections <<< "login/pass_min_days 10"
    debconf-set-selections <<< "login/pass_warn_age 7"
    dpkg-reconfigure -f noninteractive login
fi

# Password Authentication
if [ -f /etc/pam.d/common-auth ]; then
    sed -i '1 s/^/auth optional pam_tally.so deny=5 unlock_time=900 onerr=fail audit even_deny_root_account silent\n/' /etc/pam.d/common-auth
fi

# Force Strong Passwords
if ! dpkg -s libpam-cracklib >/dev/null 2>&1; then
    apt-get -y install libpam-cracklib
fi
if [ -f /etc/pam.d/common-password ]; then
    sed -i '1 s/^/password requisite pam_cracklib.so retry=3 minlen=8 difok=3 reject_username minclass=3 maxrepeat=2 dcredit=1 ucredit=1 lcredit=1 ocredit=1\n/' /etc/pam.d/common-password
fi

# Malware removal
if [ -f /etc/apt/sources.list ]; then
    apt-get -y purge hydra* john* nikto* netcat* transmisson* wireshark*
fi

# Defult Browser & Update
if ! dpkg -s firefox >/dev/null 2>&1; then
    apt-get -y install firefox
fi
update-alternatives --config x-www-browser
apt-get update

# RootKit Scan & Removal
if ! dpkg -s chkrootkit >/dev/null 2>&1; then
    apt-get -y install chkrootkit
fi
chkrootkit
apt-get purge chkrootkit -y

# Fork addons
if ! dpkg -s i3 >/dev/null 2>&1; then
    apt-get -y install i3
fi
if ! dpkg -s vim >/dev/null 2>&1; then
    apt-get -y install vim
fi

# Remove unnecessary GNOME applications
if [ -f /etc/apt/sources.list ]; then
    apt-get -y remove gnome-mahjongg gnome-mines gnome-sudoku account-plugin-facebook account-plugin-flickr account-plugin-jabber account-plugin-salut account-plugin-twitter account-plugin-windows-live account-plugin-yahoo
fi

# Media removal
if [ -f /etc/apt/sources.list ]; then
    echo "This will print all media to file media.txt"
    find / -type f \( -iname "*.mp3" -o -iname "*.mp4" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.jpg" -o -iname "*.wav" -o -iname "*.flac" -o -iname "*.mov" \) -print > /home/`whoami`/media.txt
fi

# Package listing
dpkg -l > /home/`whoami`/packages

# Install htop
if ! dpkg -s htop >/dev/null 2>&1; then
    apt-get -y install htop
fi

# MySQL
echo -n "MySQL [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]; then
    if ! dpkg -s $MYSQL_SERVER >/dev/null 2>&1; then
        debconf-set-selections <<< "mysql-server mysql-server/root_password password your_root_password"
        debconf-set-selections <<< "mysql-server mysql-server/root_password_again password your_root_password"
        apt-get -y install $MYSQL_SERVER
        # Disable remote access
        sed -i '/bind-address/ c\bind-address = 127.0.0.1' /etc/mysql/my.cnf
        service mysql restart
    fi
else
    apt-get -y purge $MYSQL_SERVER
fi

# OpenSSH server
echo -n "OpenSSH Server [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]; then
    if ! dpkg -s $OPENSSH_SERVER >/dev/null 2>&1; then
        apt-get -y install $OPENSSH_SERVER
        # Disable root login
        sed -i '/^PermitRootLogin/ c\PermitRootLogin no' /etc/ssh/sshd_config
        service ssh restart
    fi
else
    apt-get -y purge $OPENSSH_SERVER
fi

# VSFTP
echo -n "VSFTP [Y/n] "
read option
if [[ $option =~ ^[Yy]$ ]]; then
    if ! dpkg -s $VSFTPD >/dev/null 2>&1; then
        apt-get -y install $VSFTPD
        # Disable anonymous uploads
        sed -i '/^anon_upload_enable/ c\anon_upload_enable no' /etc/vsftpd.conf
        sed -i '/^anonymous_enable/ c\anonymous_enable=NO' /etc/vsftpd.conf
        # FTP user directories use chroot
        sed -i '/^chroot_local_user/ c\chroot_local_user=YES' /etc/vsftpd.conf
        service vsftpd restart
    fi
else
    apt-get -y purge $VSFTPD
fi

# Prompt user for BIOS password
read -s -p "Enter BIOS password: " bios_password
echo
# Set BIOS password
echo -n $bios_password | sudo dmidecode -s system-bios-version > /dev/null
if [ $? -eq 0 ]; then
    echo "BIOS password set successfully."
else
    echo "Failed to set BIOS password. Please check your system's documentation for instructions on how to set a BIOS password."
fi

# Purge unused packages
apt-get -y purge hydra* john* nikto* netcat* transmisson* wireshark*

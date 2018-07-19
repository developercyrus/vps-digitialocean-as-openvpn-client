#!/bin/bash
####################################################
# 
# works in DigitalOcean + Ubuntu 16.04 + IVPN
#
###################################################


# install pre-requistise
sudo apt-get install openvpn screen unzip


# download config file from IVPN
wget https://www.ivpn.net/releases/config/ivpn-openvpn-config.zip
unzip ivpn-openvpn-config.zip -d ivpn


# change the openvpn config file by changing compress method
sed -i 's/compress lzo/#compress lzo\ncomp-lzo yes/g' ~/ivpn/ivpn-openvpn-config/Germany.ovpn


# add credentials
sudo sh -c 'echo "username\npassword" >> /etc/openvpn/auth.txt'


# add auth config to openvpn config
sudo sh -c 'echo "auth-user-pass /etc/openvpn/auth.txt" >> ~/ivpn/ivpn-openvpn-config/Germany.ovpn


# add dns server from IVPN
sudo sh -c 'echo "nameserver 10.30.48.1" >> /etc/resolv.conf'


# add route, prevent ssh disconnect from the host
ip rule add from $(ip route get 1 | grep -Po '(?<=src )(\S+)') table 128
ip route add table 128 to $(ip route get 1 | grep -Po '(?<=src )(\S+)')/32 dev $(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)')
ip route add table 128 default via $(ip -4 route ls | grep default | grep -Po '(?<=via )(\S+)')


# run openvpn in detach mode
screen -d -m openvpn --config ~/ivpn/ivpn-openvpn-config/Germany.ovpn


#!/bin/bash
#
# GratWiFi Installation script
#
# (c) 2010-2013 Herman verschooten
#
echo "Installing GratWiFi Server"
echo "Installing dependant services"
apt-get remove -y resolvconf
apt-get install -y git-core dnsmasq openvpn ssh curl ipcalc ntp monit acpid bridge-utils build-essential openssl \
					libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev libxslt-dev \
					autoconf libc6-dev ncurses-dev automake libtool bison subversion

echo "Downloading gwserver"
git clone https://github.com/Herman-verschooten-bvba/gwserver.git 

cd gwserver

echo "Installing Ruby using RVM"

curl -L get.rvm.io | bash -s stable

. /usr/local/rvm/scripts/rvm


rvm install ruby-1.9.3-p392

rvm use 1.9.3 --default


echo "Copying files"
Version=$(grep -o 'Ubuntu [0-9\.]*' /etc/issue)
cp extra/motd /etc/motd.tail
cp extra/interfaces /etc/network
cp extra/gwserver.sh /etc/init.d/gwserver
cp extra/vpnwatchd.sh /etc/init.d/vpnwatchd
cp extra/setupfw /etc/init.d/setupfw
cp extra/resolv.conf.gratwifi /etc
cp extra/dnsmasq.conf /etc
cp extra/gwserver.monit /etc/monit/conf.d/gwserver
cp extra/monitrc /etc/monit

mkdir -p /opt/gwserver
cp -r lib /opt/gwserver
cp -r content /opt/gwserver
cp -r extra /opt/gwserver
cp gwserver.conf /opt/gwserver
cp main.rb /opt/gwserver
cp VERSION /opt/gwserver

touch /opt/gwserver/banned

echo "Enabling services"
update-rc.d setupfw defaults  20
update-rc.d gwserver defaults 30
update-rc.d vpnwatchd defaults 35
sed -i -e "s/startup=0/startup=1/g" /etc/default/monit

echo "Enabling routing"
sed -i 	-e "s/^#net\.ipv4\.ip_forward/net\.ipv4\.ip_forward/g"  \
	-e "s/^#net\.ipv4\.conf\.all\.log_martians/net\.ipv4\.conf\.all\.log_martians/g"  \
	-e "s/^#net\.ipv4\.conf\.all\.rp_filter/net\.ipv4\.conf\.all\.rp_filter/g"  \
	-e "s/^#net\.ipv4\.conf\.default\.rp_filter/net\.ipv4\.conf\.default\.rp_filter/g"  \
	-e "s/^#net\.ipv4\.icmp_echo_ignore_broadcast/net\.ipv4\.icmp_echo_ignore_broadcast/g"  \
	-e "s/^#net\.ipv4\.icmp_ignore_bogus_error_responses/net\.ipv4\.icmp_ignore_bogus_error_responses/g"  \
	/etc/sysctl.conf 

echo "Configure Network"

IP='192.168.198.0'
SUBNET='23'
DHCP='25'

echo -n "IP Range Router [$IP]:"
read newIP
echo -n "Bits in subnet [$SUBNET]:"
read newSUBNET
echo -n "DHCP Start [$DHCP]:"
read newDHCP

if [ "$newIP" ]; then
   IP=$newIP
fi

if [ "$newSUBNET" ]; then
   SUBNET=$newSUBNET
fi

if [ "$newDHCP" ]; then
   DHCP=$newDHCP
fi

ipc=$(ipcalc $IP/$SUBNET -b | sed "s/=.*//g" | grep : | grep -v Hosts | sed "s/:\W*/=/g" | sed "s/\//\\\\\//g")
for i in $ipc
do
  export $i
done

echo $Address
echo $Netmask
echo $Network
echo $Broadcast
echo $HostMax
DHCPStart=${Address%\.0}.$DHCP
echo $HostMin
echo $DHCPStart
sed -i -e s/STARTIP/$DHCPStart/g -e s/ENDIP/$HostMax/g /etc/dnsmasq.conf
sed -i -e s/FW_IPRANGE/$Network/g /etc/init.d/setupfw 
sed -i 	-e s/ROUTER_IP/$HostMin/g \
	-e s/ROUTER_NETMASK/$Netmask/g \
	-e s/ROUTER_BCAST/$Broadcast/g \
	-e s/ROUTER_NETWORK/$Address/g \
	/etc/network/interfaces
sed -i -e '/restrict ::1/ a\
# GratWiFi users\
restrict '$Address' mask '$Netmask' nomodify notrap
' /etc/ntp.conf

sed -i -e '/.*GratWiFi/c\'$HostMin'   GratWiFi.lan GratWiFi' /etc/hosts

echo "Reboot now? (Y/n)"
read now
if [ "$now" != "n" ]; then
 reboot
fi


#!/bin/bash
#
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
# ==================================================

# // initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- ipinfo.io/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

# // Domain
domain=$(cat /root/domain)

# // detail nama perusahaan
country=MY
state=Malaysia
locality=Malaysia
organization=jinggo
organizationalunit=jinggo
commonname=jinggo.xyz
email=jinggovpn@gmail.com

# // simple password minimal
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/SSHOVPN/password"
chmod +x /etc/pam.d/common-password

# // go to root
cd

# // Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# // nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# // Ubah izin akses
chmod +x /etc/rc.local

# // enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# // disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# // update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

# // Install Wget And Curl
apt -y install wget curl

# // Install Requirements Tools
apt install ruby -y
apt install python -y
apt install make -y
apt install cmake -y
apt install coreutils -y
apt install rsyslog -y
apt install net-tools -y
apt install zip -y
apt install unzip -y
apt install nano -y
apt install sed -y
apt install gnupg -y
apt install gnupg1 -y
apt install bc -y
apt install jq -y
apt install apt-transport-https -y
apt install build-essential -y
apt install dirmngr -y
apt install libxml-parser-perl -y
apt install git -y
apt install lsof -y
apt install libsqlite3-dev -y
apt install libz-dev -y
apt install gcc -y
apt install g++ -y
apt install libreadline-dev -y
apt install zlib1g-dev -y
apt install libssl-dev -y
apt install libssl1.0-dev -y
apt install dos2unix -y
apt install curl -y
apt install pwgen openssl netcat cron -y
apt install socat -y
echo "clear" >> .profile
echo "jinggo" >> .profile

# // set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime
date

# // set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# // install Fix
apt-get --reinstall --fix-missing install -y linux-headers-cloud-amd64 bzip2 gzip coreutils wget jq screen rsyslog iftop htop net-tools zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr libxml-parser-perl git lsof

# // Nginx
installType='apt -y install'
source /etc/os-release
release=$ID
ver=$VERSION_ID

if [[ "${release}" == "debian" ]]; then
		sudo apt install gnupg2 ca-certificates lsb-release -y 
		echo "deb http://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list 
		echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx 
		curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key 
		# gpg --dry-run --quiet --import --import-options import-show /tmp/nginx_signing.key
		sudo mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc
		sudo apt update 
                apt -y install nginx

elif [[ "${release}" == "ubuntu" ]]; then
		sudo apt install gnupg2 ca-certificates lsb-release -y 
		echo "deb http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
		echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx 
		curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key
		# gpg --dry-run --quiet --import --import-options import-show /tmp/nginx_signing.key
		sudo mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc
		sudo apt update 
                apt -y install nginx
fi

systemctl daemon-reload
systemctl enable nginx
ufw disable

# / / Make Main Directory
mkdir -p /usr/local/etc/xray/
touch /usr/local/etc/xray/vless.txt
touch /usr/local/etc/xray/vmess.txt
touch /usr/local/etc/xray/xtr.txt
touch /etc/nginx/conf.d/alone.conf
cat <<EOF >>/etc/nginx/conf.d/alone.conf
server {
             listen 80;
             listen [::]:80;
             server_name ${domain};
             ssl_certificate /usr/local/etc/xray/xray.crt;
             ssl_certificate_key /usr/local/etc/xray/xray.key;
             ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
             ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
             root /usr/share/nginx/html;

             location = /xvlessntls {
                       proxy_redirect off;
                       proxy_pass http://127.0.0.1:65432;
                       proxy_http_version 1.1;
             proxy_set_header X-Real-IP aaa;
             proxy_set_header X-Forwarded-For bbb;
             proxy_set_header Upgrade ddd;
             proxy_set_header Connection "upgrade";
             proxy_set_header Host ccc;
 }
             location = /xvmessntls {
                       proxy_redirect off;
                       proxy_pass http://127.0.0.1:23456;
                       proxy_http_version 1.1;
             proxy_set_header X-Real-IP aaa;
             proxy_set_header X-Forwarded-For bbb;
             proxy_set_header Upgrade ddd;
             proxy_set_header Connection "upgrade";
             proxy_set_header Host ccc;
 }
             location  /fallback {
                      proxy_redirect off;
                      proxy_pass http://127.0.0.1:700;
                      proxy_http_version 1.1;
              proxy_set_header Upgrade ddd;
              proxy_set_header Connection upgrade;
              proxy_set_header Host ccc;
              proxy_cache_bypass ddd;
  }
        }	
EOF

# // Move
sed -i 's/aaa/$remote_addr/g' /etc/nginx/conf.d/alone.conf
sed -i 's/bbb/$proxy_add_x_forwarded_for/g' /etc/nginx/conf.d/alone.conf
sed -i 's/ccc/$host/g' /etc/nginx/conf.d/alone.conf
sed -i 's/ddd/$http_upgrade/g' /etc/nginx/conf.d/alone.conf



# Generate certificates
systemctl stop nginx
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc
service squid start
cd
sleep 1
clear

# // Boot Nginx
mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
rm /etc/nginx/conf.d/default.conf
systemctl daemon-reload
service nginx restart
cd

# // Html
rm -rf /usr/share/nginx/html
wget -q -P /usr/share/nginx https://raw.githubusercontent.com/JinGGoVPN/DATA/main/SSHOVPN/html.zip 
unzip -o /usr/share/nginx/html.zip -d /usr/share/nginx/html 
rm -f /usr/share/nginx/html.zip*

curl https://raw.githubusercontent.com/JinGGoVPN/DATA/main/SSHOVPN/nginx.conf > /etc/nginx/nginx.conf
curl https://raw.githubusercontent.com/JinGGoVPN/DATA/main/SSHOVPN/vps.conf > /etc/nginx/conf.d/vps.conf
mkdir -p /home/vps/public_html

# // install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/SSHOVPN/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500


# // Setting Vnstat
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install
cd
vnstat -u -i $NET
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz
rm -rf /root/vnstat-2.6



# // install fail2ban
apt install -y dnsutils tcpdump dsniff grepcidr
apt -y install fail2ban

# // Instal DDOS Flate
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.ctohome.com/linux-vps-pack/soft/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.ctohome.com/linux-vps-pack/soft/ddos/ignore.ip.list

/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:" >>  /usr/local/ddos/ignore.ip.list;
chattr +i /usr/local/ddos/ignore.ip.list;

echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.ctohome.com/linux-vps-pack/soft/ddos/ddos-deflate.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'

echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'DOS-Deflate Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'


# // blockir torrent
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# // download script
cd /usr/local/bin

# // menu system
wget -O add-host "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/add-host.sh"
wget -O speedtest "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/speedtest_cli.py"
wget -O jinggo "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/jinggo.sh"
wget -O restart-service "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/XRAY/SLITE/restart-service.sh"
wget -O ram "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/ram.sh"
wget -O info "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/info.sh"
wget -O nf "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/nf.sh"
wget -O mdns "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/mdns.sh"
wget -O bbr "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/bbr.sh"

# menu
wget -O menu "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/XRAY/SLITE/menu.sh"

# // xpired
wget -O delexp "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/delexp.sh"
wget -O clear-log "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/clear-log.sh"
wget -O clearcache "https://raw.githubusercontent.com/JinGGoVPN/DATA/main/MENU/clearcache.sh"


chmod +x add-host
chmod +x speedtest
chmod +x jinggo
chmod +x restart-service
chmod +x ram
chmod +x info
chmod +x nf
chmod +x mdns
chmod +x bbr
chmod +x menu
chmod +x clear-log
chmod +x clearcache
chmod +x delexp

cd

echo "0 */12 * * * root /usr/local/bin/clear-log # clear log every  two hours" >> /etc/crontab
echo "0 */12 * * * root /usr/local/bin/clearcache  #clear cache every 12hours daily" >> /etc/crontab
echo "0 0 * * * root /usr/local/bin/delexp # delete expired user" >> /etc/crontab
echo "0 5 * * * root reboot" >> /etc/crontab

# // remove unnecessary files
cd
apt autoclean -y
apt -y remove --purge unscd
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove bind9*;
apt-get -y remove sendmail*
apt autoremove -y

# // finishing
cd
chown -R www-data:www-data /home/vps/public_html
chown -R www-data:www-data /usr/share/nginx/html

history -c
cd
rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/tools.sh
rm -f /root/domain

# // finihsing
clear
echo -e "${RED}TOOLS INSTALL DONE${NC} "
sleep 2
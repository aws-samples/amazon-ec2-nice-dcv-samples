#!/bin/zsh
cd /root/

export DEBIAN_FRONTEND=noninteractive
apt-get update

# https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu.html
apt-get install -q -y snapd
systemctl enable snapd
systemctl start snapd
sleep 2
snap install amazon-ssm-agent --classic
snap start amazon-ssm-agent

apt-get install -q -y wget tmux unzip tar curl sed
cd /root/

apt-get -q -y install kali-desktop-xfce
apt-get -q -y install pulseaudio-utils

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html
wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
gpg --import NICE-GPG-KEY
wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2204-x86_64.tgz
tar -xvzf nice-dcv-ubuntu2204-x86_64.tgz && cd nice-dcv-*-ubuntu2204-x86_64

# tweaks for installation on Kali
ln -s /etc/os-release /etc/lsb-release
mkdir -p /etc/lightdm/lightdm.conf.d

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html#linux-server-install
apt-get -q -y install ./nice-dcv-server_*_amd64.ubuntu2204.deb
apt-get -q -y install ./nice-dcv-web-viewer_*_amd64.ubuntu2204.deb
usermod -aG video dcv 
# from /etc/lightdm/lightdm.conf.d
sed -i '/^\[Seat\:\*\]/a display-setup-script=/usr/lib/x86_64-linux-gnu/dcv/dcvlightdm' /etc/lightdm/lightdm.conf

# virtual session support
apt-get -q -y install ./nice-xdcv_*_amd64.ubuntu2204.deb

# https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html
cp /etc/dcv/dcv.conf /etc/dcv/dcv.conf.org
sed -i "s/^#enable-quic-frontend=true/enable-quic-frontend=true/g" /etc/dcv/dcv.conf

# session storage: https://docs.aws.amazon.com/dcv/latest/userguide/using-transfer.html
# https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-manual
cat << EoF > /etc/systemd/system/dcv-virtual-session.service
[Unit]
Description=Create DCV virtual session
After=default.target network.target 

[Service]
ExecStart=/opt/dcv-virtual-session.sh 

[Install]
WantedBy=default.target
EoF

cat << EoF > /opt/dcv-virtual-session.sh
#!/bin/zsh
dcvUser=kali
while true;
do
  if (/usr/bin/dcv list-sessions | grep \$dcvUser 1>/dev/null)
  then
    sleep 5
  else
    /usr/bin/dcv create-session \$dcvUser --owner \$dcvUser --storage-root /home/\$dcvUser
    /usr/bin/dcv list-sessions
  fi
done
EoF
chmod +x /opt/dcv-virtual-session.sh

# remove AWSCLI version 1
apt-get remove awscli -y
apt-get autoremove -y

cd /root/
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip -q -o awscliv2.zip
./aws/install -b /usr/bin
echo "export AWS_CLI_AUTO_PROMPT=on-partial" >> /home/kali/.zshrc

# DCV update script
cat << EoF > /home/kali/update-dcv
#!/bin/zsh
cd /tmp
rm -f /tmp/nice-dcv-ubuntu2204-x86_64.tgz
wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2204-x86_64.tgz
tar -xvzf nice-dcv-ubuntu2204-x86_64.tgz && cd nice-dcv-*-ubuntu2204-x86_64
sudo dcv close-session kali
sudo systemctl stop dcvserver dcv-virtual-session
sudo apt-get install -y ./nice-dcv-server_*_amd64.ubuntu2204.deb 
sudo apt-get install -y ./nice-dcv-web-viewer_*_amd64.ubuntu2204.deb 
sudo apt-get install -y ./nice-xdcv_*_amd64.ubuntu2204.deb 
sudo sed -i "s/^#enable-quic-frontend=true/enable-quic-frontend=true/g" /etc/dcv/dcv.conf
sudo systemctl restart dcvserver dcv-virtual-session
EoF
chmod +x /home/kali/update-dcv
chown kali:kali /home/kali/update-dcv 

# AWS CLI update script
cat << EoF > /home/kali/update-awscli
#!/bin/zsh
cd /tmp
rm -f awscliv2.zip
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip -q -o awscliv2.zip
sudo ./aws/install --update -b /usr/bin
EoF
chmod +x /home/kali/update-awscli
chown kali:kali /home/kali/update-awscli   


# Fix "Authentication Required to Create Managed Color Device" prompt
cat << EoF > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EoF

# text console: DCV virtual sessions only
systemctl isolate multi-user.target
systemctl set-default multi-user.target

systemctl daemon-reload
systemctl enable --now dcvserver dcv-virtual-session.service

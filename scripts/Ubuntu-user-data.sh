#!/bin/bash
mkdir -p /tmp/cfn
cd /tmp/cfn

# https://stackoverflow.com/questions/33370297/apt-get-update-non-interactive
export DEBIAN_FRONTEND=noninteractive   

apt-get -q update
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html Note: SSH inbound required in SG
if (cat /etc/os-release | grep -q 18.04); then
  apt-get -q -y install ec2-instance-connect
fi

apt-get -q -y install python3-setuptools wget tmux unzip tar curl sed

systemctl isolate multi-user.target
if (cat /etc/os-release | grep -q 18.04); then
  apt-get -q -y install ubuntu-desktop
else
  apt-get -q -y install ubuntu-desktop-minimal 
fi
apt-get -q -y install gdm3
apt-get -q -y install pulseaudio-utils gnome-tweaks gnome-shell-extension-ubuntu-dock

# resolve "/var/lib/dpkg/info/nice-dcv-server.postinst: 8: dpkg-architecture: not found" when installing dcv-server
apt-get -q -y install dpkg-dev

sed -i "s/^#WaylandEnable=false/WaylandEnable=false/g" /etc/gdm3/custom.conf

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html
wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
gpg --import NICE-GPG-KEY

# DCV update script
cat << EoF > /home/ubuntu/update-dcv
#!/bin/bash
cd /tmp
if ((uname -a | grep -q x86) && (cat /etc/os-release | grep -q 22.04)); then
  rm -f /tmp/nice-dcv-ubuntu1804-x86_64.tgz
  wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2204-x86_64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-x86_64
elif ((uname -a | grep -q aarch) && (cat /etc/os-release | grep -q 22.04)); then
  rm -f /tmp/nice-dcv-ubuntu2204-aarch64.tgz
  wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2204-aarch64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-aarch64
elif (cat /etc/os-release | grep -q 20.04); then
  rm -f /tmp/nice-dcv-ubuntu2004-x86_64.tgz
  wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2004-x86_64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-x86_64
fi
sudo dcv close-session ubuntu
sudo systemctl stop dcvserver dcv-virtual-session
sudo apt-get install -y ./nice-dcv-server_*.deb
sudo apt-get install -y ./nice-dcv-web-viewer_*.deb
sudo apt-get install -y ./nice-xdcv_*.deb
sudo sed -i "s/^#enable-quic-frontend=true/enable-quic-frontend=true/g" /etc/dcv/dcv.conf
sudo systemctl restart dcvserver dcv-virtual-session
EoF
chmod +x /home/ubuntu/update-dcv
chown ubuntu:ubuntu /home/ubuntu/update-dcv 

# NICE DCV: https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html
if ((uname -a | grep -q x86) && (cat /etc/os-release | grep -q 22.04)); then
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2204-x86_64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-x86_64
elif ((uname -a | grep -q aarch) && (cat /etc/os-release | grep -q 22.04)); then
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2204-aarch64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-aarch64
elif ((uname -a | grep -q x86) && (cat /etc/os-release | grep -q 18.04)); then
  rm -f /home/ubuntu/update-dcv
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/2023.0/Servers/nice-dcv-2023.0-15487-ubuntu1804-x86_64.tgz
  tar -xvzf nice-dcv-*-x86_64.tgz && cd nice-dcv-*-x86_64
elif (cat /etc/os-release | grep -q 18.04); then
  rm -f /home/ubuntu/update-dcv
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/2023.0/Servers/nice-dcv-2023.0-15487-ubuntu1804-aarch64.tgz
  tar -xvzf nice-dcv-*-aarch64.tgz && cd nice-dcv-*-aarch64
else
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2004-x86_64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-x86_64
fi
apt-get -q -y install ./nice-dcv-server_*.deb
apt-get -q -y install ./nice-dcv-web-viewer_*.deb
usermod -aG video dcv 
apt-get -q -y install ./nice-xdcv_*.deb 

# QUIC: https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html
cp /etc/dcv/dcv.conf /etc/dcv/dcv.conf."`date +"%Y-%m-%d"`"
sed -i "s/^#enable-quic-frontend=true/enable-quic-frontend=true/g" /etc/dcv/dcv.conf

# Virtual session daemon: https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-manual
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
#!/bin/bash
dcvUser=ubuntu
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
apt-get -q -y remove awscli
cd /tmp/cfn
# AWS CLI v2: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
if (uname -a | grep -q x86); then
  curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
else
  curl -s https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip
fi
unzip -q -o awscliv2.zip
./aws/install -b /usr/bin
echo "export AWS_CLI_AUTO_PROMPT=on-partial" >> /home/ubuntu/.bashrc

# AWS CLI update script
cat << EoF > /home/ubuntu/update-awscli
#!/bin/bash
cd /tmp
rm -f /tmp/awscliv2.zip
if (uname -a | grep -q x86); then
  curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
else
  curl https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip
fi
unzip -q -o awscliv2.zip
sudo ./aws/install --update -b /usr/bin
EoF
chmod +x /home/ubuntu/update-awscli
chown ubuntu:ubuntu /home/ubuntu/update-awscli   

# Update OS
apt-get -q update
apt-get -q -y upgrade
apt-get -y autoremove

# text console: DCV virtual sessions only
systemctl isolate multi-user.target
systemctl set-default multi-user.target
systemctl daemon-reload

systemctl enable --now dcvserver dcv-virtual-session.service

sleep 1 && reboot

#!/bin/bash
mkdir -p /tmp/cfn
cd /tmp/cfn

# disable IPv6 during setup
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

yum install -q -y deltarpm wget tmux unzip tar curl sed
# NICE DCV prereq: https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html
yum install -q -y gdm gnome-session gnome-classic-session gnome-session-xsession
yum install -q -y xorg-x11-server-Xorg xorg-x11-fonts-Type1 xorg-x11-drivers 
yum install -q -y gnome-terminal gnu-free-fonts-common gnu-free-mono-fonts gnu-free-sans-fonts gnu-free-serif-fonts

# Microphone redirection: https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html
yum install -q -y pulseaudio pulseaudio-utils
amazon-linux-extras install -y firefox

# Disable the Wayland protocol: https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html#linux-prereq-wayland
sed -i '/^\[daemon\]/a WaylandEnable=false' /etc/gdm/custom.conf

# DCV update script
cat << EoF > /home/ec2-user/update-dcv
#!/bin/bash
cd /tmp
sudo dcv close-session ec2-user
if (uname -a | grep -q x86); then
  rm -f nice-dcv-el7-x86_64.tgz
  wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el7-x86_64.tgz
  tar -xvzf nice-dcv-el7-x86_64.tgz && cd nice-dcv-*-el7-x86_64
else
  rm -f nice-dcv-el7-aarch64.tgz
  wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el7-aarch64.tgz
  tar -xvzf nice-dcv-el7-aarch64.tgz && cd nice-dcv-*-el7-aarch64
fi
sudo systemctl stop dcvserver
sudo yum install -y ./nice-dcv-server-*.rpm
sudo yum install -y ./nice-dcv-web-viewer-*.rpm
sudo yum install -y ./nice-xdcv-*.rpm
sudo systemctl restart dcvserver
EoF
chmod +x /home/ec2-user/update-dcv
chown ec2-user:ec2-user /home/ec2-user/update-dcv

# NICE DCV: https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html
rpm --import https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
if (uname -a | grep -q x86); then
  curl -s -L -O https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el7-x86_64.tgz
  tar -xzf nice-dcv-el7-x86_64.tgz && cd nice-dcv-*-el7-x86_64
else
  curl -s -L -O https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el7-aarch64.tgz
  tar -xzf nice-dcv-el7-aarch64.tgz && cd nice-dcv-*-el7-aarch64
fi
yum install -q -y ./nice-dcv-server-*.rpm
yum install -q -y ./nice-dcv-web-viewer-*.rpm
yum install -q -y ./nice-xdcv-*.rpm

# QUIC: https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html
cp /etc/dcv/dcv.conf /etc/dcv/dcv.conf."`date +"%Y-%m-%d"`"
sed -i "s/^#enable-quic-frontend=true/enable-quic-frontend=true/g" /etc/dcv/dcv.conf

# Virtual session: https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-manual
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
dcvUser=ec2-user
while true;
do
  if (/usr/bin/dcv list-sessions | grep -q \$dcvUser); then
    sleep 5
  else
    /usr/bin/dcv create-session \$dcvUser --owner \$dcvUser --storage-root /home/\$dcvUser
    /usr/bin/dcv list-sessions
  fi
done
EoF
chmod +x /opt/dcv-virtual-session.sh

# AWS CLI update script
cat << EoF > /home/ec2-user/update-awscli
#!/bin/bash
cd /tmp
rm -f awscliv2.zip
if (uname -a | grep -q x86); then
  curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
else
  curl https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip
fi
unzip -q -o awscliv2.zip
sudo ./aws/install --update -b /usr/bin
EoF
chmod +x /home/ec2-user/update-awscli
chown ec2-user:ec2-user /home/ec2-user/update-awscli

# remove AWSCLI version 1
dnf remove -q -y awscli

cd /tmp/cfn
# AWS CLI v2: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
if (uname -a | grep -q x86); then
  curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
else
  curl -s https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip
fi
unzip -q -o awscliv2.zip
./aws/install -b /usr/bin
echo "export AWS_CLI_AUTO_PROMPT=on-partial" >> /home/ec2-user/.bashrc

# Update OS
yum update -q -y
# yum-cron
yum install -q -y yum-cron
sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
systemctl enable --now yum-cron

# enable back IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=0
sysctl -w net.ipv6.conf.default.disable_ipv6=0

# text console: DCV virtual sessions only
systemctl isolate multi-user.target
systemctl set-default multi-user.target
systemctl daemon-reload

systemctl enable --now dcvserver dcv-virtual-session

sleep 1 && reboot
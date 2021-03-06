#!/bin/bash
cd /root/

# https://stackoverflow.com/questions/33370297/apt-get-update-non-interactive
export DEBIAN_FRONTEND=noninteractive   

apt-get update
# https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu.html#agent-install-ubuntu-tabs


# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/releasehistory-aws-cfn-bootstrap.html#releasehistory-aws-cfn-bootstrap-v1
apt-get -q -y install python3-setuptools wget tmux unzip tar curl sed

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html
systemctl isolate multi-user.target

apt-get -q -y install ubuntu-desktop 
apt-get -q -y install gdm3

apt-get -q -y install pulseaudio-utils
# resolve "/var/lib/dpkg/info/nice-dcv-server.postinst: 8: dpkg-architecture: not found" when installing dcv-server
apt-get -q -y install dpkg-dev

sed -i "s/^#WaylandEnable=false/WaylandEnable=false/g" /etc/gdm3/custom.conf

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html
wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
gpg --import NICE-GPG-KEY

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html#linux-server-install
if ((uname -a | grep x86 1>/dev/null) && (cat /etc/os-release | grep 22.04 1>/dev/null)); then
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2204-x86_64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-x86_64
elif ((uname -a | grep x86 1>/dev/null) && (cat /etc/os-release | grep 18.04 1>/dev/null)); then
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu1804-x86_64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-x86_64
elif (cat /etc/os-release | grep 18.04 1>/dev/null); then
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu1804-aarch64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-aarch64
else
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2004-x86_64.tgz
  tar -xvzf nice-dcv-ubuntu*.tgz && cd nice-dcv-*-x86_64  
fi   
apt-get -q -y install ./nice-dcv-server_*.deb
apt-get -q -y install ./nice-dcv-web-viewer_*.deb
usermod -aG video dcv 
apt-get -q -y install ./nice-xdcv_*.deb 

# https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html
cp /etc/dcv/dcv.conf /etc/dcv/dcv.conf.org
sed -i '/^\[connectivity/a enable-quic-frontend=true' /etc/dcv/dcv.conf

# session storage: https://docs.aws.amazon.com/dcv/latest/userguide/using-transfer.html
mkdir -p /home/ubuntu/DCV-Storage
chown -R ubuntu:ubuntu /home/ubuntu/DCV-Storage

# https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-manual
cat << EoF > /etc/systemd/system/dcv-virtual-session.service
[Unit]
Description=Create DCV virtual session for user ubuntu
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
    /usr/bin/dcv create-session \$dcvUser --owner \$dcvUser --storage-root /home/\$dcvUser/DCV-Storage
    /usr/bin/dcv list-sessions
  fi
done
EoF
chmod +x /opt/dcv-virtual-session.sh

cd /root/
apt-get -y autoremove
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
if (uname -a | grep x86 1>/dev/null); then
  curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
else
  curl -s https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip
fi
unzip -q -o awscliv2.zip
./aws/install -b /usr/bin
echo "export AWS_CLI_AUTO_PROMPT=on-partial" >> /home/ubuntu/.bashrc

# text console: DCV virtual sessions only
systemctl isolate multi-user.target
systemctl set-default multi-user.target

systemctl daemon-reload
systemctl enable --now dcvserver dcv-virtual-session.service

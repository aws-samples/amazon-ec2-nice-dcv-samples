#!/bin/zsh
cd /root/

# https://stackoverflow.com/questions/33370297/apt-get-update-non-interactive
export DEBIAN_FRONTEND=noninteractive   
apt-get update

# https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu.html
apt-get install -y snapd
systemctl enable --now snapd
systemctl start snapd
sleep 2
snap install amazon-ssm-agent --classic
snap start amazon-ssm-agent

# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/releasehistory-aws-cfn-bootstrap.html#releasehistory-aws-cfn-bootstrap-v1
apt-get -q -y install python3-setuptools wget tmux unzip tar curl sed

cd /root/
apt-get -q -y install kali-desktop-xfce
apt-get -q -y install pulseaudio-utils 

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html
wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
gpg --import NICE-GPG-KEY
wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-ubuntu2004-x86_64.tgz
tar -xvzf nice-dcv-ubuntu2004-x86_64.tgz && cd nice-dcv-*-ubuntu2004-x86_64

# tweaks for installation on Kali
ln -s /etc/os-release /etc/lsb-release
mkdir -p /etc/lightdm/lightdm.conf.d

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html#linux-server-install
apt-get -q -y install ./nice-dcv-server_*_amd64.ubuntu2004.deb
apt-get -q -y install ./nice-dcv-web-viewer_*_amd64.ubuntu2004.deb
usermod -aG video dcv 
# from /etc/lightdm/lightdm.conf.d
sed -i '/^\[Seat\:\*\]/a display-setup-script=/usr/lib/x86_64-linux-gnu/dcv/dcvlightdm' /etc/lightdm/lightdm.conf

# virtual session support
apt-get -q -y install ./nice-xdcv_*_amd64.ubuntu2004.deb

# https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html
cp /etc/dcv/dcv.conf /etc/dcv/dcv.conf.org
sed -i '/^\[connectivity/a enable-quic-frontend=true' /etc/dcv/dcv.conf

# session storage: https://docs.aws.amazon.com/dcv/latest/userguide/using-transfer.html
# https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-manual
cat << EoF > /etc/systemd/system/dcv-virtual-session.service
[Unit]
Description=Create DCV virtual session for user kali
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

# text console: DCV virtual sessions only
systemctl isolate multi-user.target
systemctl set-default multi-user.target

systemctl daemon-reload
systemctl enable --now dcvserver dcv-virtual-session.service

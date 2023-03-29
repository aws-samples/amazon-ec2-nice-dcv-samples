#!/bin/bash
cd /root/

# https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-al2.html
if (uname -a | grep x86 1>/dev/null)
then
  yum install -q -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
else
  yum install -q -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
fi

yum install -q -y deltarpm wget tmux unzip tar curl sed
# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html
yum install -q -y gdm gnome-session gnome-classic-session gnome-session-xsession
yum install -q -y xorg-x11-server-Xorg xorg-x11-fonts-Type1 xorg-x11-drivers 
yum install -q -y gnome-terminal gnu-free-fonts-common gnu-free-mono-fonts gnu-free-sans-fonts gnu-free-serif-fonts

yum install -q -y pulseaudio pulseaudio-utils

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html
rpm --import https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY

if (uname -a | grep x86 1>/dev/null)
then
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el7-x86_64.tgz
  tar -xvzf nice-dcv-el7-x86_64.tgz && cd nice-dcv-*-el7-x86_64
else
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el7-aarch64.tgz
  tar -xvzf nice-dcv-el7-aarch64.tgz && cd nice-dcv-*-el7-aarch64
fi
yum install -q -y nice-dcv-server-*.rpm
yum install -q -y nice-dcv-web-viewer-*.rpm
yum install -q -y nice-xdcv-*.rpm

# Firefox
amazon-linux-extras install -y firefox

# https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html
cp /etc/dcv/dcv.conf /etc/dcv/dcv.conf.org
sed -i '/^\[connectivity/a enable-quic-frontend=true' /etc/dcv/dcv.conf

# session storage: https://docs.aws.amazon.com/dcv/latest/userguide/using-transfer.html
# https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-manual
cat << EoF > /etc/systemd/system/dcv-virtual-session.service
[Unit]
Description=Create DCV virtual session for user ec2-user
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
  if (/usr/bin/dcv list-sessions | grep \$dcvUser 1>/dev/null); then
    sleep 5
  else
    /usr/bin/dcv create-session \$dcvUser --owner \$dcvUser --storage-root /home/\$dcvUser
    /usr/bin/dcv list-sessions
  fi
done
EoF
chmod +x /opt/dcv-virtual-session.sh

cd /root/
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
yum remove awscli -y
if (uname -a | grep x86 1>/dev/null)
then
  curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
else
  curl -s https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip
fi
unzip -q -o awscliv2.zip
./aws/install -b /usr/bin
echo "export AWS_CLI_AUTO_PROMPT=on-partial" >> /home/ec2-user/.bashrc

# yum-cron
yum install -q -y yum-cron
sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf
systemctl enable --now yum-cron

# text console: DCV virtual sessions only
systemctl isolate multi-user.target
systemctl set-default multi-user.target

systemctl daemon-reload
systemctl enable --now dcvserver dcv-virtual-session.service

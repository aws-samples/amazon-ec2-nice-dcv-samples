#!/bin/bash
cd /root/

dnf install -q -y python3 python3-setuptools wget tmux unzip tar curl sed

# https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-rhel.html
if (uname -a | grep x86 1>/dev/null); then
  sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
else
  sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_arm64/amazon-ssm-agent.rpm
fi
systemctl enable --now amazon-ssm-agent

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html
yum groupinstall -q -y 'Server with GUI'
systemctl isolate multi-user.target

sed -i "s/^#WaylandEnable=false/WaylandEnable=false/g" /etc/gdm/custom.conf
yum install -q -y pulseaudio pulseaudio-utils

# https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html
rpm --import https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY

if ((uname -a | grep x86 1>/dev/null) && (cat /etc/os-release | grep 8. 1>/dev/null)); then  
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el8-x86_64.tgz
  tar -xvzf nice-dcv-el8-x86_64.tgz && cd nice-dcv-*-el8-x86_64
elif ((uname -a | grep aarch64 1>/dev/null) && (cat /etc/os-release | grep 8. 1>/dev/null)); then
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el8-aarch64.tgz
  tar -xvzf nice-dcv-el8-aarch64.tgz && cd nice-dcv-*-el8-aarch64
else
  wget -nv https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el9-x86_64.tgz
  tar -xvzf nice-dcv-el9-x86_64.tgz && cd nice-dcv-*-el9-x86_64       
fi

yum install -y nice-dcv-server-*.rpm
yum install -y nice-dcv-web-viewer-*.rpm
yum install -y nice-xdcv-*.rpm

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
yum install -q -y dnf-automatic
sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer

# DCV update script
cat << EoF > /home/ec2-user/update-dcv
#!/bin/bash
cd /tmp
if ((uname -a | grep x86 1>/dev/null) && (cat /etc/os-release | grep 8. 1>/dev/null)); then
  rm -f nice-dcv-el8-x86_64.tgz
  wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el8-x86_64.tgz
  tar -xvzf nice-dcv-el8-x86_64.tgz && cd nice-dcv-*-el8-x86_64
elif ((uname -a | grep aarch64 1>/dev/null) && (cat /etc/os-release | grep 8. 1>/dev/null)); then
  rm -f nice-dcv-el8-aarch64.tgz
  wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el8-aarch64.tgz
  tar -xvzf nice-dcv-el8-aarch64.tgz && cd nice-dcv-*-el8-aarch64
else
  rm -f nice-dcv-el9-x86_64.tgz 
  wget https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-el9-x86_64.tgz
  tar -xvzf nice-dcv-el9-x86_64.tgz && cd nice-dcv-*-el9-x86_64
fi
sudo dcv close-session ec2-user
sudo systemctl stop dcvserver dcv-virtual-session
sudo yum install -y ./nice-dcv-server-*.rpm
sudo yum install -y ./nice-dcv-web-viewer-*.rpm
sudo yum install -y ./nice-xdcv-*.rpm
sudo sed -i "s/^#enable-quic-frontend=true/enable-quic-frontend=true/g" /etc/dcv/dcv.conf
sudo systemctl restart dcvserver dcv-virtual-session
EoF
chmod +x /home/ec2-user/update-dcv
chown ec2-user:ec2-user /home/ec2-user/update-dcv 

# AWS CLI update script
cat << EoF > /home/ec2-user/update-awscli
#!/bin/bash
cd /tmp
rm -f awscliv2.zip
if (uname -a | grep x86 1>/dev/null)
then
  curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
else
  curl https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip
fi
unzip -q -o awscliv2.zip
sudo ./aws/install --update -b /usr/bin
EoF
chmod +x /home/ec2-user/update-awscli
chown ec2-user:ec2-user /home/ec2-user/update-awscli  

# Add NICE DCV ports (https://firewalld.org/documentation/man-pages/firewall-offline-cmd.html)
# Get around ":dbus.proxies:Introspect error on :1.170:/org/fedoraproject/FirewallD" error
systemctl stop firewalld
firewall-offline-cmd  --add-port 8443/tcp
firewall-offline-cmd  --add-port 8443/udp
systemctl disable firewalld

# text console: DCV virtual sessions only
systemctl isolate multi-user.target
systemctl set-default multi-user.target

systemctl daemon-reload
systemctl enable --now dcvserver dcv-virtual-session.service

<script>
@echo off
cd \windows\temp\

@echo ** https://docs.chocolatey.org/en-us/choco/setup
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-winprereq.html#setting-up-installing-general 
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-virtual-display-x64-Release.msi', 'nice-dcv-virtual-display-x64-Release.msi')"
msiexec.exe /i nice-dcv-virtual-display-x64-Release.msi /quiet /l dcv-display.log

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-wininstall.html
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi', 'nice-dcv-server-x64-Release.msi')"
msiexec.exe  /i nice-dcv-server-x64-Release.msi ADDLOCAL=ALL /quiet /norestart /l*v dcv_install_msi.log

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-auto
reg add HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\session-management\automatic-console-session /v owner /t REG_SZ /d "administrator" /f 
reg add HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\session-management /v create-session /t REG_DWORD /d 1 /f

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/manage-storage.html
reg add HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\session-management\automatic-console-session /v storage-root /t REG_SZ /d C:/Users/Administrator/ /f 

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html
reg add HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\connectivity /v enable-quic-frontend /t REG_DWORD /d 1 /f

@echo ** install AWSCLI
choco install --no-progress -y awscli
setx /M AWS_CLI_AUTO_PROMPT on-partial

@echo ** install Chololatey GUI
choco install --no-progress -y chocolateygui 

@echo ** Restarting DCV 
net stop dcvserver
net start dcvserver

@echo ** https://docs.aws.amazon.com/systems-manager/latest/userguide/fleet-rdp.html#fleet-rdp-prerequisites
powershell -command "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.4.201 -Force"
powershell -command "Install-Module -Name PSReadLine -Repository PSGallery -MinimumVersion 2.2.2 -Force"
</script>

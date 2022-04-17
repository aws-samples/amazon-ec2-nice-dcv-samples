<script>
@echo off
cd \windows\temp\

@echo ** https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-install-win.html
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe', 'AmazonSSMAgentSetup.exe')"
c:\windows\temp\AmazonSSMAgentSetup.exe /S

@echo ** https://docs.chocolatey.org/en-us/choco/setup
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

rem install Curl if not present
IF NOT EXIST c:\windows\system32\curl cinst --no-progress -y curl

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-winprereq.html#setting-up-installing-general 
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-virtual-display-x64-Release.msi', 'nice-dcv-virtual-display-x64-Release.msi')"
msiexec.exe /i nice-dcv-virtual-display-x64-Release.msi /quiet /l dcv-display.log

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-wininstall.html
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi', 'nice-dcv-server-x64-Release.msi')"
msiexec.exe  /i nice-dcv-server-x64-Release.msi ADDLOCAL=ALL /quiet /norestart /l*v dcv_install_msi.log

@echo ** https://docs.aws.amazon.com/dcv/latest/userguide/client-windows.html
powershell -command "(New-Object System.Net.WebClient).DownloadFile('https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-client-Release.msi', 'nice-dcv-client-Release.msi')"
msiexec.exe /i nice-dcv-client-Release.msi ADDLOCAL=ALL /quiet /norestart /l*v dcv_client_install_msi.log

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-auto
reg add HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\session-management\automatic-console-session /v owner /t REG_SZ /d "administrator" /f 
reg add HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\session-management /v create-session /t REG_DWORD /d 1 /f

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/manage-storage.html
mkdir C:\DCV-Storage\
reg add HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\session-management\automatic-console-session /v storage-root /t REG_SZ /d C:/DCV-Storage/ /f 
powershell -command "$shortcut=(New-Object -ComObject WScript.Shell).CreateShortcut('C:\Users\Administrator\Desktop\DCV-Storage.lnk');$shortcut.TargetPath='C:\DCV-Storage\';$shortcut.Save()"

@echo ** https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html
reg add HKEY_USERS\S-1-5-18\Software\GSettings\com\nicesoftware\dcv\connectivity /v enable-quic-frontend /t REG_DWORD /d 1 /f

@echo ** install AWSCLI
cinst --no-progress -y awscli
setx /M AWS_CLI_AUTO_PROMPT on-partial      

@echo ** Restarting DCV 
net stop dcvserver
net start dcvserver    
</script>  
## Notice
Operating systems such as AlmaLinux, Debian, Kali Linux, and those that have reached end of life *are not supported* by NICE DCV and may not work. Usage indicates acceptance of [NICE DCV EULA](https://www.nice-dcv.com/eula.html) and license agreements of all software that is installed in the EC2 instance. Refer to [NICE DCV documentation site](https://docs.aws.amazon.com/dcv/latest/adminguide/servers.html#requirements) for list of supported operating systems.


## About CloudFormation templates
EC2 instances must be provisioned in a subnet with IPv4 internet connectivity. 

When using a MarketPlace AMI such as [Rocky Linux](https://aws.amazon.com/marketplace/seller-profile?id=01538adc-2664-49d5-b926-3381dffce12d), [AlmaLinux](https://aws.amazon.com/marketplace/seller-profile?id=529d1014-352c-4bed-8b63-6120e4bd3342), [CentOS](https://aws.amazon.com/marketplace/seller-profile?id=045847c6-6990-4bdb-b490-0b159744e3a4) or [Kali Linux](https://aws.amazon.com/marketplace/seller-profile?id=3fd16b5c-a3f6-43b5-b254-0a6ae8f6a350), subscribe before using. 


Verify [availablity](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/instance-discovery.html) of the instance type that you specify. (Refer to [Why am I receiving the error "Your requested instance type is not supported in your requested Availability Zone" when launching an EC2 instance?](https://repost.aws/knowledge-center/ec2-instance-type-not-supported-az-error)) Marketplace AMIs may only support specific [instance types](https://docs.aws.amazon.com/marketplace/latest/userguide/ami-single-ami-products.html#single-ami-adding-instance-types), visit the corresponding Marketplace page to view available options.

For templates that offers both x86_64 and arm64 options, ensure that the instance type you specify matches your selected processor architecture.

## Deployment via CloudFormation console
Download `<OS>-NICE-DCV.yaml` CloudFormation file where `<OS>` is the desired operating system, and login to AWS [CloudFormation console](https://console.aws.amazon.com/cloudformation/home#/stacks/create/template). Start the [Create Stack wizard](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html#cfn-using-console-initiating-stack-creation) by choosing **Create Stack**. [Select stack template](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-using-console-create-stack-template.html) by selecting **Upload a template file**, **Choose File**, select your `.yaml` file and click **Next**. Enter a **Stack name** and specify parameters values. 

### CloudFormation Parameters
In most cases, the default values are sufficient. You will need to specify values for `vpcID`, `subnetID` and `ec2KeyPair` (Linux only).


Version
- `osVersion` (where applicable): operating system version and processor architecture (Intel/AMD x86_64 or [Graviton](https://aws.amazon.com/ec2/graviton/) arm64). Default is latest version and arm64
- `imageId` (where applicable): [System Manager Parameter](https://aws.amazon.com/blogs/compute/using-system-manager-parameter-as-an-alias-for-ami-id/) path to AMI ID

EC2
- `ec2Name`: name of EC2 instance
- `ec2KeyPair` (Linux): [EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) for [SSH access](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-linux-inst-ssh.html#connect-linux-inst-sshClient). [Create a key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html) if you do not have one
-  `instanceType`: appropriate [instance type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html).  Default is `t4g.medium` and `t3.medium` for arm64 and x86_64 architecture respectively

NICE DCV
- `driverType` (Windows): choose between [NICE-DCV](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-winprereq.html#setting-up-installing-general) (Windows Server 2016), [NVIDIA GRID](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-nvidia-driver.html#nvidia-GRID-driver) or [NVIDIA Gaming](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-nvidia-driver.html#nvidia-gaming-driver) ([G4dn](https://aws.amazon.com/ec2/instance-types/g4/) and [G5](https://aws.amazon.com/ec2/instance-types/g5/) instance), [NVIDIA Tesla](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-nvidia-driver.html#public-nvidia-driver) ([NVIDIA GPU instance](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/accelerated-computing-instances.html#gpu-instances)), [AMD Radeon Pro](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-amd-driver.html#download-amd-driver) ([G4ad](https://aws.amazon.com/ec2/instance-types/g4/) instance) graphics driver or `none` not to install any driver. Default is `none`.
- `sessionType` (Linux): `virtual` or `console` [NICE DCV sessions](https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions.html#managing-sessions-intro). Default is `virtual` with *multi-user.target* as default systemd target. Selecting `console` will change systemd default to *graphical.target*. [GPU driver installation](#gpu-driver-installation) option may be available for some Linux OSs
- `teslaDriverVersion` (where applicable): [Tesla driver version](https://docs.nvidia.com/datacenter/tesla/index.html) to install when `NVIDIA-Tesla` or `console-with-NVIDIA_Tesla_runfile_Driver` option is selected for `driverType` or `sessionType` respectively. To find the correct driver version, go to [NVIDIA Driver Downloads](https://www.nvidia.com/Download/Find.aspx). Select the **Product Type**, **Product Series**, and **Product** values for your `instanceType` as per [To download a public NVIDIA driver](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#public-nvidia-driver) table and the correct **Operating System**
- `listenPort`: NICE DCV server TCP and UDP [listen ports](https://docs.aws.amazon.com/dcv/latest/adminguide/manage-port-addr.html). Number must be higher than 1024 and default is `8443`


Networking
- `vpcID`: [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) with internet connectivity. Select [default VPC](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html) if unsure
- `subnetID`: subnet with internet connectivity. Select subnet in default VPC if unsure. If you specify a different `instanceType`, ensure that it is available in AZ subnet you select
- `displayPublicIP`: set this to `No` for EC2 instance in a subnet that will not receive [public IP address](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#concepts-public-addresses). EC2 private IP will be displayed in CloudFormation Outputs section instead. Default is `Yes`
- `assignStaticIP`: associates a static public IPv4 address using [Elastic IP address](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) to prevent assigned IPv4 address from changing every time EC2 instance is stopped and started. There is a hourly charge when instance is stopped as listed at [Elastic IP Addresses on Amazon EC2 Pricing, On-Demand Pricing page](https://aws.amazon.com/ec2/pricing/on-demand/#Elastic_IP_Addressesv). Default is `Yes`

Allowed IP prefix
- `ingressIPv4`: allowed IPv4 source prefix to NICE DCV and SSH(Linux) ports, e.g. `1.2.3.4/32`. Get source IP from [https://checkip.amazonaws.com](https://checkip.amazonaws.com). Default is `0.0.0.0/0`
- `ingressIPv6`: allowed IPv6 source prefix to NICE DCV and SSH(Linux) ports. Use `::1/128` to block all incoming IPv6 access. Default is `::/0`

EBS Volume
- `volumeSize`: EBS root volume size in GiB
- `volumeType`: `gp2` or `gp3` [general purpose](https://aws.amazon.com/ebs/general-purpose/) EBS type. Default is `gp3`

Continue **Next** with [Configure stack options](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-add-tags.html), [Review Stack](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-using-console-create-stack-review.html), and click **Submit** to launch your stack. 

It may take more than 30 minutes to provision the EC2 instance. After your stack has been successfully created, its status changes to **CREATE_COMPLETE**.

### CloudFormation Outputs
The following are available in **Outputs** section 
- `SSMsessionManager`: [SSM Session Manager](https://aws.amazon.com/blogs/aws/new-session-manager/) URL link. Use this to change login user password. Password change command is in *Description* field.
- `DCVwebConsole`: NICE DCV web browser console URL link. Login as user specified in *Description* field. 
- `EC2console`: EC2 console URL link to manage EC2 instance or to get the latest IPv4 (or IPv6 if enabled) address.
- `EC2instanceConnect` (if available, Linux): [in-browser SSH](https://aws.amazon.com/blogs/compute/new-using-amazon-ec2-instance-connect-for-ssh-access-to-your-ec2-instances/) URL link. Functionality is only available under [certain conditions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-prerequisites.html).
- `RDPconnect` (Windows): in-browser [Fleet Manager Remote Desktop](https://aws.amazon.com/blogs/mt/console-based-access-to-windows-instances-using-aws-systems-manager-fleet-manager/) URL link. Use this to update NICE DCV server.

## Using NICE DCV
Refer to [NICE DCV User Guide](https://docs.aws.amazon.com/dcv/latest/userguide/getting-started.html)

### NICE DCV clients
Besides web browser client, NICE DCV offers Windows, Linux, and macOS native clients with additional features such as [QUIC UDP](https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html), [multi-channel audio](https://docs.aws.amazon.com/dcv/latest/adminguide/manage-audio.html) and [gamepad support](https://docs.aws.amazon.com/dcv/latest/adminguide/enable-gamepad.html). Native clients can be download from [https://download.nice-dcv.com/](https://download.nice-dcv.com/). 

### Remove web browser client
On Linux instances, the web browser client can be disabled by removing `nice-dcv-web-viewer` package. On Windows instances, download [nice-dcv-server-x64-Release.msi](https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi) and run the command *msiexec /i nice-dcv-server-x64-Release.msi REMOVE=webClient* from administrator command prompt.


## About Windows template
The blog [Building a high-performance Windows workstation on AWS for graphics intensive applications](https://aws.amazon.com/blogs/compute/building-a-high-performance-windows-workstation-on-aws-for-graphics-intensive-applications/) walks through use of [Windows Server template](WIndowsServer-NICE-DCV.yaml) to provision and manage a GPU Windows instance.  

Default Windows AMI is now Windows Server 2022 English-Full-Base. You can retrieve SSM paths to other AMIs from [Parameter Store console](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-finding-public-parameters.html#paramstore-discover-public-console), [AWS CloudShell](https://aws.amazon.com/cloudshell/) or [AWS CLI](https://aws.amazon.com/cli/). Refer to [Query for the Latest Windows AMI Using Systems Manager Parameter Store](https://aws.amazon.com/blogs/mt/query-for-the-latest-windows-ami-using-systems-manager-parameter-store/) blog for more information.

If you provision a supported [GPU graphics instance](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/accelerated-computing-instances.html#gpu-instances), you can choose to specify which graphics driver to install. Note that the NVIDIA GRID, NVIDIA Gaming and AMD drivers are for AWS customers only and you are bound by conditions and terms as per [Install NVIDIA drivers on Windows instances](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-nvidia-driver.html) and [Install AMD drivers on Windows instances](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-amd-driver.html). 

Use `download-<DRIVER-TYPE>-driver.cmd` helper batch files in *C:\\Users\\Administrator\\* folder to download the latest NVIDIA GRID, NVIDIA gaming or AMD GPU drivers from AWS. Refer to [Prerequisites for accelerated computing instances](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-winprereq.html#setting-up-installing-graphics) for driver installation and configuration instructions. 

To update NICE DCV Server, connect via Fleet Manager Remote Desktop console using `RDPconnect` link and run `C:\Users\Administrator\update-DCV.cmd`


## About Linux templates
The login user name depends on Linux distributions as follows:
- [AlmaLinux](AlmaLinux-NICE-DCV.yaml), [Amazon Linux 2](AmazonLinux2-NICE-DCV.yaml), [CentOS Stream 9](CentOSstream9-NICE-DCV.yaml), [RHEL](RHEL-NICE-DCV.yaml), [SLES](SLES-NICE-DCV.yaml) : ec2-user
- [CentOS 7](CentOS7-NICE-DCV.yaml), [CentOS Stream 8](CentOSstream8-NICE-DCV.yaml) : centos
- [Debian](Debian-NICE-DCV.yaml) : admin
- [Kali Linux](KaliLinux-NICE-DCV.yaml) : kali
- [Rocky Linux](RockyLinux-NICE-DCV.yaml) : rocky
- [Ubuntu, Ubuntu Pro](Ubuntu-NICE-DCV.yaml) : ubuntu

You can use update scripts (`update-dcv`, `update-awscli`) in */home/{user name}* folder via SSM Session Manager or EC2 Instance Connect to update NICE DCV and AWS CLI. 

### Console and virtual sessions
NICE DCV offers two types of sessions: console sessions and virtual sessions. With console sessions, NICE DCV directly captures the content of the desktop screen. With virtual sessions, NICE DCV starts an X server instance, Xdcv, and runs a desktop environment inside the X server. 
Refer to [Introduction to NICE DCV sessions](https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions.html#managing-sessions-intro) for more details.


### GPU driver installation
On [GPU EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#gpu-instances) with GPU drivers installed and configured, NICE DCV console sessions have direct access to the GPU, providing features such as GPU accelerated OpenGL and hardware accelerated video streaming encoding (screen shot below). For best results, connect to your EC2 instance using [native client](#nice-dcv-clients).

<img alternate="NICE DCV server on g4dn with NVIDA GRID drive" src="../images/nice-dcv-nvidia-grid-60fps.png">

GPU driver installation is available for some Linux distros ([AlmaLinux](AlmaLinux-NICE-DCV.yaml), [Amazon Linux 2](AmazonLinux2-NICE-DCV.yaml), [RHEL](RHEL-NICE-DCV.yaml), [Rocky Linux](RockyLinux-NICE-DCV.yaml), [SLES](SLES-NICE-DCV.yaml), [Ubuntu](Ubuntu-NICE-DCV.yaml)) via the following `sessionType` parameter options:

- `console-with-Ubuntu_repo_Driver` (Ubuntu only): install latest NVIDIA [Enterprise Ready Drivers (ERD)](https://ubuntu.com/server/docs/nvidia-drivers-installation) from Ubuntu repository
- `console-with-NVIDIA_GRID_Driver` or `console-with-NVIDIA_Gaming_Driver` ([G4dn](https://aws.amazon.com/ec2/instance-types/g4/) and [G5](https://aws.amazon.com/ec2/instance-types/g5/) instance)#: install [NVIDIA GRID](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-GRID-driver) (also known as [NVIDIA RTX Virtual Workstation (vWS)](https://www.nvidia.com/en-us/design-visualization/virtual-workstation/)) or [NVIDIA Gaming](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-gaming-driver) drivers

- `console-with-NVIDIA_Tesla_repo_Driver` (NVIDIA [GPU instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-driver-instance-type) such as [G5g instance](https://aws.amazon.com/ec2/instance-types/g5g/)): uses the operating system [package manager](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html#package-manager) to install [NVIDIA Tesla](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#public-nvidia-driver) (also known as [NVIDIA Data Center GPU](https://docs.nvidia.com/datacenter/tesla/drivers/index.html)) drivers from [NVIDIA repository](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/contents.html), and provides access to [CUDA packages](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#meta-packages)

-  `console-with-NVIDIA_Tesla_runfile_Driver`: install NVIDIA Tesla driver using [.run installer package](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html#runfile) from [driver downloads](https://www.nvidia.com/Download/index.aspx). Use `teslaDriverVersion` to specify the [driver version](https://docs.nvidia.com/datacenter/tesla/index.html) to install

- `console-with-AMD_ROCm_repo_Driver`([G4ad instance](https://aws.amazon.com/ec2/instance-types/g4/)) : uses the operating system [package manager](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/native-install/index.html) to install AMD GPU drivers from [AMD](https://rocm.docs.amd.com/en/latest/) repository, and provides access to [ROCm packages](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/how-to/native-install/package-manager-integration.html#packages-in-rocm-programming-models)

Note that due to different combinations of drivers, OSs and instance types, GPU driver installation via CloudFormation template may not work. You can select `console` option and install driver manually. Refer to [Prerequisites for Linux NICE DCV servers](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html#linux-prereq-gpu) for details about NICE DCV GPU driver installation and configuration.

#NVIDIA GRID and NVIDIA gaming drivers are for AWS customers only. You are bound by conditions and terms as per [Install NVIDIA drivers on Linux instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html). Helper scripts (`install-<DRIVER_TYPE>-driver`) in */home/{user name}* folder can be used to install or update the GPU drivers. 


## EC2 in private subnet
The CloudFormation templates are designed to provision EC2 instances in [public subnet](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario1.html). To use them for EC2 instances in [private subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html) with internet connectivity, set `displayPublicIP` and `assignStaticIP` parameter values to `No`.


## EC2 in Local Zones
To use templates in [AWS Local Zones](https://aws.amazon.com/about-aws/global-infrastructure/localzones/), verify [available services features](https://aws.amazon.com/about-aws/global-infrastructure/localzones/features/) and adjust CloudFormation parameters accordingly. For example, you may have to change `osVersion`, `instanceType` and `volumeType`, and set `assignStaticIP` to `No`.

## Securing EC2 instance
To futher secure your EC2 instance, you may want to
- [Remove web browser client](#remove-web-browser-client) and use [native client](https://download.nice-dcv.com/)
- Restrict NICE DCV and SSH to your IP address only (`ingressIPv4` and `ingressIPv6`).
- Disable SSH access from public internet (Linux only). Use [EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html#ec2-instance-connect-connecting-console) or [SSM Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html#start-ec2-console) for in-browser terminal access. If you have [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and [Session Manager plugin for the AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) installed, you can start a session using [AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html#sessions-start-cli) or [SSH](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html#sessions-start-ssh).
- Backup data in your EC2 instances with [EBS snapshots](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSSnapshots.html). You can setup automatic snapshots using [Amazon Data Lifecycle Manager](https://aws.amazon.com/blogs/storage/automating-amazon-ebs-snapshot-and-ami-management-using-amazon-dlm/) or [AWS Backup](https://aws.amazon.com/blogs/aws/aws-backup-ec2-instances-efs-single-file-restore-and-cross-region-backup/) (with [AWS Backup Vault Lock](https://aws.amazon.com/blogs/storage/enhance-the-security-posture-of-your-backups-with-aws-backup-vault-lock/) for enhanced security posture).
- Enable [Amazon GuardDuty](https://aws.amazon.com/guardduty/) security monitoring service with [Malware Protection](https://docs.aws.amazon.com/guardduty/latest/ug/malware-protection.html) to detect the potential presence of malware in EBS volumes.
- If you are hosting a website, use [Amazon CloudFront](https://aws.amazon.com/cloudfront/) with [AWS WAF](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-web-awswaf.html) to protect your instance from DDoS and common web attacks. The [Accelerate and protect your websites using Amazon CloudFront and AWS WAF](https://aws.amazon.com/blogs/networking-and-content-delivery/accelerate-and-protect-your-websites-using-amazon-cloudfront-and-aws-waf/) blog post and [CloudFront dynamic websites](https://github.com/aws-samples/amazon-cloudfront-dynamic-websites) CloudFormation template may help with CloudFront distribution setup.

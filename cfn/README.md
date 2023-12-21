## Notice
Operating systems such as AlmaLinux and Kali Linux and those that have reached end of life *are not supported* by NICE DCV and may not work. Usage indicates acceptance of [NICE DCV EULA](https://www.nice-dcv.com/eula.html). Refer to [documentation site](https://docs.aws.amazon.com/dcv/latest/adminguide/servers.html#requirements) for list of supported operating systems.


## About CloudFormation templates
When using a MarketPlace AMI such as [Rocky Linux](https://aws.amazon.com/marketplace/seller-profile?id=01538adc-2664-49d5-b926-3381dffce12d), [AlmaLinux](https://aws.amazon.com/marketplace/seller-profile?id=529d1014-352c-4bed-8b63-6120e4bd3342), [CentOS](https://aws.amazon.com/marketplace/seller-profile?id=045847c6-6990-4bdb-b490-0b159744e3a4) or [Kali Linux](https://aws.amazon.com/marketplace/seller-profile?id=3fd16b5c-a3f6-43b5-b254-0a6ae8f6a350), subscribe before using.  If you specify a different instance type, do verify its availablity. Refer to [Why am I receiving the error "Your requested instance type is not supported in your requested Availability Zone" when launching an EC2 instance?](https://repost.aws/knowledge-center/ec2-instance-type-not-supported-az-error).



## Deployment via CloudFormation console
Download desired template file and login to AWS [CloudFormation console](https://console.aws.amazon.com/cloudformation/home#/stacks/create/template). Choose **Create Stack**, **Upload a template file**, **Choose File**, select your `.yaml` file and choose **Next**. Enter a **Stack name** and specify parameters values. 

### CloudFormation Parameters
In most cases, the default values are sufficient. You will need to specify values for `ec2KeyPair`, `vpcID` and `subnetID`. 


Version
- `osVersion` (where applicable): operating system version and processor architecture (Intel/AMD x86_64 or [Graviton](https://aws.amazon.com/ec2/graviton/) arm64). Default is latest version and arm64
- `imageId` (where applicable): [System Manager Parameter](https://aws.amazon.com/blogs/compute/using-system-manager-parameter-as-an-alias-for-ami-id/) path to AMI ID

EC2
- `ec2Name`: name of EC2 instance
- `ec2KeyPair` (Linux only): [EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html). [Create a key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html) if you do not have one
- `driverType` (Windows Server only): choose between NICE-DCV, NVIDIA GRID, NVIDIA Gaming and AMD GPU driver, or select none not to install any graphics driver. Default is `NICE-DCV`
-  `instanceType`: appropriate [instance type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html).  Default is `t4g.medium` and `t3.medium` for ARM and x86_64 architecture respectively.

Networking
- `vpcID`: [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) with internet connectivity. Select [default VPC](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html) if unsure
- `subnetID`: subnet with internet connectivity. Select subnet in default VPC if unsure. If you specify a different `instanceType`, ensure that it is available in AZ subnet you select. 
- `displayPublicIP`: set this to `No` if you provision EC2 instance in a subnet that will not receive [public IP address](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#concepts-public-addresses). EC2 private IP will be displayed in CloudFormation Outputs section instead. Default is `Yes`
- `assignStaticIP`: as the auto-assigned public IP address changes every time EC2 instance is stopped and started, this option associates a static public IPv4 address using [Elastic IP address](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html). There is a hourly charge when instance is stopped as listed at [Elastic IP Addresses on Amazon EC2 Pricing, On-Demand Pricing page](https://aws.amazon.com/ec2/pricing/on-demand/#Elastic_IP_Addressesv). Default is `Yes`

Allowed IP prefix
- `ingressIPv4`: allowed IPv4 source prefix to NICE DCV and SSH(Linux only) ports, e.g. `1.2.3.4/32`. Get source IP from [https://checkip.amazonaws.com](https://checkip.amazonaws.com). Default is `0.0.0.0/0`
- `ingressIPv6`: allowed IPv6 source prefix to NICE DCV and SSH(Linux only) ports. Use `::1/128` to block all incoming IPv6 access. Default is `::/0`

EBS Volume
- `volumeSize`: EBS root volume size in GiB
- `volumeType`: `gp2` or `gp3` [general purpose](https://aws.amazon.com/ebs/general-purpose/) EBS type. Default is `gp3`

NICE DCV
- `listenPort`: NICE DCV server TCP/UDP [listen ports](https://docs.aws.amazon.com/dcv/latest/adminguide/manage-port-addr.html). Number must be higher than 1024 and default is `8443`
- `sessionType` (Linux only): `virtual` or `console` [NICE DCV sessions](https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions.html#managing-sessions-intro). Default is `virtual`. GPU driver installation may be available for some distros. Refer to [GPU driver installation](#gpu-driver-installation) section below for details
- `teslaDriverVersion` (Linux only): NVIDIA [driver version](https://docs.nvidia.com/datacenter/tesla/index.html) to install when `console_Tesla_runfile_Driver` or `virtual_Tesla_runfile_Driver` option is selected under `sessionType`

Continue **Next** with [Configure stack options](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-add-tags.html), [Review](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-using-console-create-stack-review.html) settings, and click **Create Stack** to launch your stack. 

It may take more than 30 minutes to provision the EC2 instance. After your stack has been successfully created, its status changes to **CREATE_COMPLETE**.

### CloudFormation Outputs
The following are available on **Outputs** section 
- `SSMSessionManager`: [SSM Session Manager](https://aws.amazon.com/blogs/aws/new-session-manager/) URL link. Use this to change login user password. Password change command is in *Description* field.
- `DCVwebConsole`: NICE DCV web browser console URL link. Login as user specified in *Description* field. 
- `EC2console`: EC2 console URL link to manage EC2 instance or to get the latest IPv4 (or IPv6 if enabled) address.
- `EC2instanceConnect` (some Linux only): [in-browser SSH](https://aws.amazon.com/blogs/compute/new-using-amazon-ec2-instance-connect-for-ssh-access-to-your-ec2-instances/) URL link. Feature may not be available in your [Region](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-prerequisites.html#eic-prereqs-regions), and only work if security group allow inbound SSH from [EC2_INSTANCE_CONNECT](https://github.com/aws-samples/ec2-lamp-server#ec2-instance-connect-ip-prefixes) IP address range.
- `RDPconnect` (Windows only): in-browser RDP via [Fleet Manager](https://aws.amazon.com/blogs/mt/console-based-access-to-windows-instances-using-aws-systems-manager-fleet-manager/) URL link. Use this to update NICE DCV server.

## Using NICE DCV
Refer to [NICE DCV User Guide](https://docs.aws.amazon.com/dcv/latest/userguide/getting-started.html)

### NICE DCV clients
Besides web browser client, NICE DCV offers Windows, Linux, and macOS native clients with additional features such as [QUIC UDP](https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html), [multi-channel audio](https://docs.aws.amazon.com/dcv/latest/adminguide/manage-audio.html) and [gamepad support](https://docs.aws.amazon.com/dcv/latest/adminguide/enable-gamepad.html). Native clients can be download from [https://download.nice-dcv.com/](https://download.nice-dcv.com/). 

### Remove web browser client
On Linux instances, the web browser client can be disabled by removing `nice-dcv-web-viewer` package. On Windows instances, download [nice-dcv-server-x64-Release.msi](https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi) and run the command *msiexec /i nice-dcv-server-x64-Release.msi REMOVE=webClient* from administrator command prompt.


## Notes about Windows Server template
The blog [Building a high-performance Windows workstation on AWS for graphics intensive applications](https://aws.amazon.com/blogs/compute/building-a-high-performance-windows-workstation-on-aws-for-graphics-intensive-applications/) walks through use of Windows Server template to provision and manage a GPU Windows instance.  

Default Windows AMI is now Windows Server 2022 English-Full-Base. You can retrieve SSM paths to other AMIs from [Parameter Store console](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-finding-public-parameters.html#paramstore-discover-public-console), [AWS CloudShell](https://aws.amazon.com/cloudshell/) or [AWS CLI](https://aws.amazon.com/cli/). Refer to [Query for the Latest Windows AMI Using Systems Manager Parameter Store](https://aws.amazon.com/blogs/mt/query-for-the-latest-windows-ami-using-systems-manager-parameter-store/) blog for more information.

If you provision a supported [GPU graphics instance](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/accelerated-computing-instances.html#gpu-instances), you can choose to specify which graphics driver to install. Note that the drivers are for AWS customers only and you are bound by conditions and terms as per [Install NVIDIA drivers on Windows instances](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-nvidia-driver.html) and [Install AMD drivers on Windows instances](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-amd-driver.html). 

Use `C:\Users\Administrator\download-<DRIVER-TYPE>-driver.cmd` helper batch file to download the latest NVIDIA GRID, NVIDIA gaming and AMD GPU drivers from AWS. Refer to [Prerequisites for accelerated computing instances](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-winprereq.html#setting-up-installing-graphics) for driver installation and configuration instructions. 

To update NICE DCV Server, connect via Fleet Manager Remote Desktop console using `RDPconnect` link and run `C:\Users\Administrator\update-DCV.cmd`


## Notes about Linux templates
The login user name depends on Linux distributions as follows:
- Amazon Linux 2, AlmaLinux, RHEL, CentOS Stream 9 : ec2-user
- Rocky Linux : rocky
- Ubuntu, [Ubuntu Pro](https://aws.amazon.com/about-aws/whats-new/2023/04/amazon-ec2-ubuntu-pro-subscription-model/) : ubuntu
- Kali Linux : kali
- CentOS 7, CentOS Stream 8 : centos

You can use update scripts (`update-dcv`, `update-awscli`) in */home/{user name}* folder via SSM Session Manager or EC2 Instance Connect to update NICE DCV and AWS CLI. 

### Console and virtual session
NICE DCV offers two types of sessions: console sessions and virtual sessions. With console sessions, NICE DCV directly captures the content of the desktop screen. With virtual sessions, NICE DCV starts an X server instance, Xdcv, and runs a desktop environment inside the X server. 
Refer to [Introduction to NICE DCV sessions](https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions.html#managing-sessions-intro) for more details.


### GPU driver installation
For [GPU EC2 instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#gpu-instances) with GPU drivers installed and configured, NICE DCV console sessions have direct access to the GPU, providing features such as NVENC hardware accelerated H.264 video streaming encoding and increased maximum resolution.

As per [Available drivers by instance type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-driver-instance-type), [NVIDIA GRID](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-GRID-driver) and [NVIDIA Gaming](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-gaming-driver) drivers can be installed on [G4dn](https://aws.amazon.com/ec2/instance-types/g4/) and [G5](https://aws.amazon.com/ec2/instance-types/g5/) instance types. These drivers can be selected under CloudFormation `sessionType` parameter option as `console_NVIDIA_GRID_Driver` and `console_NVIDIA_Gaming_Driver` respectively. Helper scripts (`install-<DRIVER_TYPE>-driver`) in */home/{user name}* folder can be used to install or update NVIDIA GRID, NVIDIA gaming or AMD GPU drivers. Note that NVIDIA GRID/gaming and AMD drivers are for AWS customers only. You are bound by conditions and terms as per [Install NVIDIA drivers on Linux instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html) and [Install AMD drivers on Linux instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-amd-driver.html). Refer to [Prerequisites for Linux NICE DCV servers](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html#linux-prereq-gpu) for other details about NICE DCV GPU driver installation and configuration.

[Public NVIDIA Tesla drivers](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#public-nvidia-driver) are available for other supported [GPU accelerated instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-driver-instance-type) such as [G5g instance type](https://aws.amazon.com/ec2/instance-types/g5g/). The drivers can be installed by selecting `virtual/console_NVIDIA_Tesla_repo_Driver` or `virtual/console_NVIDIA_Tesla_runfile_Driver` under `sessionType` CloudFormation parameter option. The `repo_Driver` option uses the operating system [package manager](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html#package-manager) to install from [NVIDIA repository](https://developer.download.nvidia.com/compute/cuda/repos/), while `runfile_Driver` option downloads NVIDIA [.run installer package](https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html#runfile) from NVIDIA [driver downloads](https://www.nvidia.com/Download/index.aspx) site.  Some drivers may not be available from [NVIDIA repository](https://developer.download.nvidia.com/compute/cuda/repos/rhel9/aarch64/) but may be available via [runfile option](https://www.nvidia.com/Download/driverResults.aspx/214056/en-us/). Some OS (e.g. [Ubuntu](https://ubuntu.com/server/docs/nvidia-drivers-installation)) may have their own NVIDIA driver repository; select `console` `sessionType` to install driver manually. 

Note that NVIDIA driver installation options may not work due to dynamic nature of different combinations of drivers and OS. 

## EC2 in private subnet
The CloudFormation templates are designed to provision EC2 instances in [public subnet](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario1.html). To use them for EC2 instances in [private subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html) with internet connectivity, set `displayPublicIP` parameter value to `No`  


## EC2 in Local Zones
To use template in [AWS Local Zones](https://aws.amazon.com/about-aws/global-infrastructure/localzones/), verify [available services](https://aws.amazon.com/about-aws/global-infrastructure/localzones/features/) and adjust CloudFormation parameters accordingly. For example, you may have to change `version`, `instanceType` and `volumeType`  with `assignStaticIP` set to `No`

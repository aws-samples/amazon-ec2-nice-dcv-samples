## Notice
Some distributions such as AlmaLinux and Kali Linux *are not officially supported* by NICE DCV and may not work. Usage indicates acceptance of [NICE DCV EULA](https://www.nice-dcv.com/eula.html). Refer to [documentation site](https://docs.aws.amazon.com/dcv/latest/adminguide/servers.html#requirements) for  information.


## About CloudFormation templates
The CloudFormation templates do not detect and install graphics drivers for [accelerated GPU instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#gpu-instances), but provide helper scripts to download them. [Windows Server](WIndowsServer-NICE-DCV.yaml) template do provide option to install NICE-DCV, NVIDIA GRID, NVIDIA gaming or AMD GPU driver. Refer to notes below for more information. 

When using a MarketPlace AMI such as [Rocky Linux](https://aws.amazon.com/marketplace/pp/prodview-2otariyxb3mqu) or [AlmaLinux](https://aws.amazon.com/marketplace/pp/prodview-mku4y3g4sjrye?), subscribe before provisioning CloudFormation stack. 


## Deployment via CloudFormation console
Download desired template file and login to AWS [CloudFormation console](https://console.aws.amazon.com/cloudformation/home#/stacks/create/template). Choose **Create Stack**, **Upload a template file**, **Choose File**, select your .YAML file and choose **Next**. Specify a **Stack name** and specify parameters values. 

### CloudFormation Parameters
In most cases, the default values are sufficient. You will need to specify a VPC and subnet to provision EC2 instance in. 
- `version` (Linux only): version and processor architecture (Intel/AMD x86_64 or [Graviton](https://aws.amazon.com/ec2/graviton/) where applicable). Default is latest version and arm64
- `imageId`: [System Manager Parameter](https://aws.amazon.com/blogs/compute/using-system-manager-parameter-as-an-alias-for-ami-id/) path to AMI ID. For [RHEL 8/9](https://access.redhat.com/solutions/15356) and [Rocky Linux 8/9](https://rockylinux.org/cloud-images/), go to indicated web page to retrieve AMI ID for your AWS Region
-  `instanceType`: appropriate [instance type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html). Due to memory demands of running graphical environment, 4 GB or more RAM instance types are recommended. If you specify a different instance type, do verify its availablity. Refer to [Why am I receiving the error "Your requested instance type is not supported in your requested Availability Zone" when launching an EC2 instance?](https://repost.aws/knowledge-center/ec2-instance-type-not-supported-az-error). You can also use AWS CLI, e.g. `aws ec2 describe-instance-type-offerings --output table --location-type availability-zone --region us-east-1 --filter "Name=instance-type,Values=g4ad.xlarge"` checks availablity of g4ad.xlarge instance type in us-east-1 Region.
- `driverType` (Windows Server only): choose between NICE-DCV, NVIDIA GRID, NVIDIA Gaming and AMD GPU driver, or select none not to install any graphics driver. Default is `NICE-DCV`
- `ec2Name`: name of EC2 instance
- `ec2KeyPair`: [EC2 key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) name
- `vpcID`: [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) with internet connectivity. Select [default VPC](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html) if unsure
- `subnetID`: subnet with internet connectivity. Select subnet in default VPC if unsure. If you specify a different `instanceType`, ensure that it is available in AZ subnet you select. 
- `ingressIPv4`: allowed IPv4 source prefix, e.g. `1.2.3.4/32`. Get source IP from [https://checkip.amazonaws.com](https://checkip.amazonaws.com)
- `ingressIPv6`: allowed IPv6 source prefix. Use `::1/128` to block all incoming IPv6 access
- `displayPublicIP`: set this to `No` if you provision EC2 instance in a subnet that will not receive [public IP address](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html#concepts-public-addresses). EC2 private IP will be displayed in CloudFormation Outputs section instead. Default is `Yes`
- `assignStaticIP`: as the auto-assigned public IP address changes every time EC2 instance is stopped and started, this option associates a static public IPv4 address using [Elastic IP address](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html). There is a small hourly charge when instance is stopped. For more information, see [Elastic IP Addresses on Amazon EC2 Pricing, On-Demand Pricing page](https://aws.amazon.com/ec2/pricing/on-demand/). Default is `No`
- `volumeSize`: EBS root volume size. Value must be equal or larger than AMI snapshot size
- `volumeType`: EBS [general purpose](https://aws.amazon.com/ebs/general-purpose/) type. Default is `gp3`
- `listenPort`: NICE DCV server TCP/UDP listen ports. Default is `8443`

Continue **Next** with [Configure stack options](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-add-tags.html), [Review](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-using-console-create-stack-review.html) settings, and click **Create Stack** to launch your stack. 

It may take up to 60 minutes to provision the EC2 instance. After your stack has been successfully created, its status changes to **CREATE_COMPLETE**.

### CloudFormation Outputs
The following are available on **Outputs** section 
- `SSMSessionManager`: SSM Session Manager URL link to change login user password. Password change command is in *Description* field.
- `DCVwebConsole`: NICE DCV web browser console URL link to login as the user specified in *Description* field. 
- `EC2Instance`: EC2 console URL link to start/stop your EC2 instance or to get the latest IPv4 (or IPv6 if enabled) address.
- `RdpConnect` (Windows Server only): RDP console access via [Fleet Manager](https://aws.amazon.com/blogs/mt/console-based-access-to-windows-instances-using-aws-systems-manager-fleet-manager/) URL link. Use this to update NICE DCV server

## Using NICE DCV
Refer to [NICE DCV User Guide](https://docs.aws.amazon.com/dcv/latest/userguide/getting-started.html)

### NICE DCV clients
Besides web browser client, NICE DCV offers Windows, Linux, and macOS native clients with additional features such as [QUIC UDP](https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html), [multi-channel audio](https://docs.aws.amazon.com/dcv/latest/adminguide/manage-audio.html) and [gamepad support](https://docs.aws.amazon.com/dcv/latest/adminguide/enable-gamepad.html). Native clients can be download from [https://download.nice-dcv.com/](https://download.nice-dcv.com/). 

### Remove web browser client
On Linux instances, the web browser client can be disabled by removing `nice-dcv-web-viewer` package. On Windows instances, download [nice-dcv-server-x64-Release.msi](https://d1uj6qtbmh3dt5.cloudfront.net/nice-dcv-server-x64-Release.msi) and run the command *msiexec /i nice-dcv-server-x64-Release.msi REMOVE=webClient* from administrator command prompt.


## Notes about Windows Server template
The blog [Building a high-performance Windows workstation on AWS for graphics intensive applications](https://aws.amazon.com/blogs/compute/building-a-high-performance-windows-workstation-on-aws-for-graphics-intensive-applications/) walks through use of Windows Server template to provision and manage a GPU Windows instance.  

Default Windows AMI is now Windows Server 2022 English-Full-Base. You can retrieve SSM paths to other AMIs from [Parameter Store console](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-finding-public-parameters.html#paramstore-discover-public-console) or from [AWS CLI](https://aws.amazon.com/cli/) (e.g. `aws ssm get-parameters-by-path --path /aws/service/ami-windows-latest --query "Parameters[].Name"`). Refer to [Query for the Latest Windows AMI Using Systems Manager Parameter Store](https://aws.amazon.com/blogs/mt/query-for-the-latest-windows-ami-using-systems-manager-parameter-store/) blog for more information.

If you provision a supported [GPU graphics instance](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/accelerated-computing-instances.html#gpu-instances), you can choose to specify which graphics driver to install. Note that the drivers are for AWS customers only and you are bound by conditions and terms as per [Install NVIDIA drivers on Windows instances](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-nvidia-driver.html) and [Install AMD drivers on Windows instances](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-amd-driver.html). 

Use `C:\Users\Administrator\download-<DRIVER-TYPE>-driver.cmd` helper batch file to download the latest NVIDIA GRID, NVIDIA gaming and AMD GPU drivers from AWS. Refer to [Prerequisites for accelerated computing instances](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-winprereq.html#setting-up-installing-graphics) for driver installation and configuration instructions. 

To update NICE DCV Server, connect via Fleet Manager Remote Desktop console using `RdpConnect` link and run `C:\Users\Administrator\update-DCV.cmd`


## Notes about Linux templates
[Virtual sessions](https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-manual) instead of console sessions are used, and system is configured with systemd multi-user.target. To ensure availability of virtual session, a custom daemon processs `dcv-virtual-session.service` polls for and creates a new virtual session when none are found. 
The login user name depends on Linux distributions as follows:
- Amazon Linux 2, AlmaLinux, RHEL : ec2-user
- Rocky Linux : rocky
- Ubuntu Linux: ubuntu
- Kali Linux: kali

You can use update scripts (`update-dcv`, `update-awscli`) in */home/{user name}* folder via SSM Session Manager session to update NICE DCV and AWS CLI. 

As the provisioning process install graphical desktop and other libraries, you may want to [reboot the EC2 instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-reboot.html) before logging in. Some templates support ARM64 architecture; specify a [Graviton](https://aws.amazon.com/ec2/graviton/) instance type (e.g. t4g.medium) if you choose ARM64 option. 

If you provision a supported [GPU graphics instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#gpu-instances), you may use helper scripts */home/{user name}/download-<DRIVER_TYPE>-driver* to download NVIDIA GRID, NVIDIA gaming or AMD GPU drivers.  Note that the drivers are for AWS customers only and you are bound by conditions and terms as per [Install NVIDIA drivers on Linux instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html) and [Install AMD drivers on Linux instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-amd-driver.html). Refer to [Prerequisites for Linux NICE DCV servers](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html) for driver installation and configuration instructions.


## EC2 in private subnet
The CloudFormation templates are designed to provision EC2 instances in [public subnet](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario1.html). To use them for EC2 instances in [private subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html) with internet connectivity, set `displayPublicIP` parameter value to `No`  


## EC2 in Local Zones
To use template in [AWS Local Zones](https://aws.amazon.com/about-aws/global-infrastructure/localzones/), verify [available services](https://aws.amazon.com/about-aws/global-infrastructure/localzones/features/) and adjust CloudFormation parameters according. For example, you may have to change `version`, `instanceType` and `volumeType`  with `assignStaticIP` set to `No`
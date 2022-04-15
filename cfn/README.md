## About CloudFormation templates
The CloudFormation templates do not install GPU drivers for [accelerated computing instances](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-winprereq.html#setting-up-installing-graphics). Some distributions may not be officially supported; refer to [documentation site](https://docs.aws.amazon.com/dcv/index.html) for more information. Usage of templates indicates acceptance of [NICE DCV EULA](https://www.nice-dcv.com/eula.html).

If using a MarketPlace AMI such as [Kali Linux](https://aws.amazon.com/marketplace/pp/prodview-fznsw3f7mq7to) or [AlmaLinux](https://aws.amazon.com/marketplace/pp/prodview-mku4y3g4sjrye?), go to MarketPlace to subscribe before provisioning CloudFormation stack. 


## Deployment via CloudFormation console
Download desired template file and login to AWS [CloudFormation console](https://console.aws.amazon.com/cloudformation/home#/stacks/create/template). Choose **Create Stack**, **Upload a template file**, **Choose File**, select your .YAML file and choose **Next**.

Specify a **Stack name** and specify parameters values. All fields are required. 
- `imageId`:[System Manager Parameter](https://aws.amazon.com/blogs/compute/using-system-manager-parameter-as-an-alias-for-ami-id/) path to AMI ID. 
-  `instanceType`: appropriate [instance type](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html). Due to memory demands of running graphical environment, 4 GB or more RAM instance types are recommended
- `ec2Name`: name for your EC2 instance
- `keyName`: [key pair name](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
- `vpcID`: [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) with internet connectivity. Select your [default VPC](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html) if unsure
- `subnetID`: subnet with internet connectivity. Select subnet in your default VPC if unsure
- `ingressIPv4`: allowed IPv4 source prefixes to NICE DCV listening ports at 8443
- `ingressIPv6`: allowed IPv6 source prefixes to NICE DCV listening ports at 8443

![CloudFormation parameters](/images/parameters.png "Parameters")

Continue **Next** with [Configure stack options](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-add-tags.html), [Review](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-using-console-create-stack-review.html) settings, and click **Create Stack** to launch your stack. 

It may take up to 30 minutes to provision the EC2 instance. After your stack has been successfully created, its status changes to **CREATE_COMPLETE**.
Go to **Outputs** tab
![CloudFormation Outputs](/images/outputs.png "Outputs")

Go to `SSMSessionManager` key, open *Value* URL (in the form `https://<REGION>.console.aws.amazon.com/systems-manager/session-manager/<InstanceID>`) in a new browser tab to login via SSM session manager and change the login user password. Password change command is in *Description* field.

Open DCVwebConsole value URL (in the form `https://<EC2 Public IP>:8443/`) to access web browser console and login as the user as specified in Description field. 

## NICE DCV clients

Besides web browser client, NICE DCV offers Windows, Linux, and macOS native clients with additional features such as [QUIC UDP support](https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html). Native clients can be download from [https://download.nice-dcv.com/](https://download.nice-dcv.com/). 

## Using NICE DCV
Refer to [NICE DCV User Guide](https://docs.aws.amazon.com/dcv/latest/userguide/getting-started.html)

## Notes about Windows Server template
Default Windows AMI is Windows Server 2019 English-Full-Base. You can retrieve SSM paths to other AMIs from [Parameter Store console](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-finding-public-parameters.html#paramstore-discover-public-console) or from [AWS CLI](https://aws.amazon.com/cli/) (e.g. `aws ssm get-parameters-by-path --path /aws/service/ami-windows-latest --query "Parameters[].Name"`). For more information, refer to [Query for the Latest Windows AMI Using Systems Manager Parameter Store](https://aws.amazon.com/blogs/mt/query-for-the-latest-windows-ami-using-systems-manager-parameter-store/) blog post
 
Note that the CloudFormation template was only tested with Windows Server 2016/2019/2022 English Full Base.

## Notes about Linux templates
As these are not GPU accelerated instances, [virtual sessions](https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions-start.html#managing-sessions-start-manual) instead of console sessions are used, and system is configured with systemd multi-user.target. To ensure availability of virtual session, a custom daemon processs `dcv-virtual-session.service` polls for existence of virtual session and creates a new session when none are found. 
The login user name depends on Linux distributions as follows:
- Amazon Linux 2 / AlmaLinux* : ec2-user
- Ubuntu: ubuntu
- Kali Linux*: kali

For templates that support ARM64 architecture, specify a Graviton instance type (e.g. t4g.medium).





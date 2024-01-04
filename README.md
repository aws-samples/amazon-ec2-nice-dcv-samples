## amazon-ec2-nice-dcv-samples 
Collection of sample [AWS CloudFormation](https://aws.amazon.com/cloudformation/) templates to provision Linux or Windows [Amazon EC2](https://aws.amazon.com/ec2/) instances with GUI (graphical user interface) running [NICE DCV](https://aws.amazon.com/hpc/dcv/) server. Includes option to install NVIDIA or AMD GPU drivers. 

## Description
[NICE DCV](https://aws.amazon.com/hpc/dcv/) is a high-performance remote visualisation protocol that enables users to securely connect to remote desktops and application streaming in the cloud from any device. To use, [install NICE DCV server software](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing.html) and remotely connect to the server using [web browser](https://docs.aws.amazon.com/dcv/latest/userguide/client-web.html) (screenshot below) or [native client](https://www.nice-dcv.com/latest.html). 

<img alternate="NICE DCV web browser client" src="images/nice-dcv-Ubuntu.png">


NICE DCV client do not require a license while NICE DCV server requires [licensing](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-license.html). A license is not required for NICE DCV server on [Amazon EC2](https://aws.amazon.com/ec2/) if they can access [Amazon S3](https://aws.amazon.com/s3/) endpoint for [license verification](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-license.html#setting-up-license-ec2).


The CloudFormation templates provision EC2 instances running NICE DCV server with the following features:
- [GNOME](https://www.gnome.org/) desktop environment (Linux)
- [Web browser client](https://docs.aws.amazon.com/dcv/latest/userguide/client-web.html) 
- [Adaptable display resolution](https://docs.aws.amazon.com/dcv/latest/userguide/changing-resolution.html)
- [QUIC UDP transport protocol](https://docs.aws.amazon.com/dcv/latest/adminguide/enable-quic.html)
- [Copy and Paste](https://docs.aws.amazon.com/dcv/latest/userguide/using-copy-paste.html#using-copy-paste-browser)
- [File transfer](https://docs.aws.amazon.com/dcv/latest/userguide/using-transfer-web.html)
- [Audio](https://docs.aws.amazon.com/dcv/latest/adminguide/manage-audio.html)
- [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) browser-based terminal access
- [EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-linux-inst-eic.html) browser-based SSH (some [Linux distros](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html))
- [Fleet Manager Remote Desktop](https://docs.aws.amazon.com/systems-manager/latest/userguide/fleet-rdp.html) browser-based RDP (Windows)
- [AWS CLI v2](https://aws.amazon.com/blogs/developer/aws-cli-v2-is-now-generally-available/) with [partial mode](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-parameters-prompting.html#cli-usage-auto-prompt-modes) [auto-prompt](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-parameters-prompting.html) 
- [gp3 or gp2](https://aws.amazon.com/ebs/general-purpose/) volume type with option to specify volume size
- [EC2 IAM role](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) for [NICE DCV license verification](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-license.html#setting-up-license-ec2), [AWS Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-permissions.html) and S3 bucket access to [NVIDIA](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html) and [AMD](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-amd-driver.html) [GPU](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/accelerated-computing-instances.html#gpu-instances) drivers 
- Associate static, public IPv4 address via [Elastic IP](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-eips.html) (optional)
- Specify NICE DCV server TCP and UDP [listen ports](https://docs.aws.amazon.com/dcv/latest/adminguide/manage-port-addr.html) 
- Virtual or console [session](https://docs.aws.amazon.com/dcv/latest/adminguide/managing-sessions.html#managing-sessions-intro)
- [NVIDIA GRID, Gaming, Tesla](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-driver-types) or [AMD](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-amd-driver.html) GPU drivers (optional: Windows and some Linux distros)


## Deployment and using NICE DCV
Refer to [cfn](cfn) section for instructions.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

## Notice
Usage indicates acceptance of [NICE DCV EULA](https://www.nice-dcv.com/eula.html). Some distributions *are not supported* by NICE DCV.  Refer to [documentation site](https://docs.aws.amazon.com/dcv/latest/adminguide/servers.html#requirements) for information.


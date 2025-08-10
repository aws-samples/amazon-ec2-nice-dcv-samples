## Amazon-EC2-NICE-DCV-Samples
[AWS CloudFormation](https://aws.amazon.com/cloudformation/) templates that provision Windows or Linux [Amazon EC2](https://aws.amazon.com/ec2/) GUI (graphical user interface) instances running [Amazon DCV](https://aws.amazon.com/hpc/dcv/) remote display protocol server. Supports GPU driver install and [AWS Deep Learning AMIs](https://aws.amazon.com/ai/machine-learning/amis/). 

## Description
[Amazon DCV](https://aws.amazon.com/hpc/dcv/) is a high-performance remote visualisation protocol that enables users to securely connect to remote desktops in the cloud from any device. To use, install a [desktop environment and desktop manager](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-prereq.html#linux-prereq-gui) (Linux), [install DCV server software](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing.html), and remotely connect to the server using [web browser](https://docs.aws.amazon.com/dcv/latest/userguide/client-web.html) (screenshot below) or [native client](https://www.amazondcv.com/latest.html). 

DCV client do not require a license while DCV server requires [licensing](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-license.html). A license is not required for DCV server on Amazon EC2 if they can access Amazon S3 endpoint for [license verification](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-license.html#setting-up-license-ec2).

### Features
The CloudFormation templates provision EC2 instances running DCV server with the following features:
- [GNOME](https://www.gnome.org/) desktop environment (Linux)
- [Amazon DCV](https://aws.amazon.com/hpc/dcv/) server with most [features](https://docs.aws.amazon.com/dcv/latest/userguide/client-features.html) implemented including
  - [HTML 5 web browser client](https://docs.aws.amazon.com/dcv/latest/userguide/client-web.html) 
  - [Copy and Paste](https://docs.aws.amazon.com/dcv/latest/userguide/using-copy-paste.html)
  - [File transfer](https://docs.aws.amazon.com/dcv/latest/userguide/using-transfer.html)
  - [Printing](https://docs.aws.amazon.com/dcv/latest/userguide/using-print.html)
  - Specify DCV server TCP and UDP [listen port](https://docs.aws.amazon.com/dcv/latest/adminguide/manage-port-addr.html) 
- GPU
  - [NVIDIA GRID, Gaming, Tesla](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/install-nvidia-driver.html#nvidia-driver-types) or [AMD](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/install-amd-driver.html) driver install (optional: Windows and some Linux OSs)
  - [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/) to run GPU-accelerated containers (optional)
  - DCV [GPU sharing](https://docs.aws.amazon.com/dcv/latest/adminguide/manage-gpu.html) (optional)
- Administration and Data Protection
  - [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) browser-based terminal access
  - [EC2 Instance Connect](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connect-linux-inst-eic.html) browser-based SSH (Linux)
  - [Fleet Manager Remote Desktop](https://docs.aws.amazon.com/systems-manager/latest/userguide/fleet-rdp.html) browser-based RDP (Windows)
  - [EC2 IAM role](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) for [DCV license verification](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-license.html#setting-up-license-ec2), [Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-permissions.html), [CloudWatch agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-iam-roles-for-cloudwatch-agent.html#create-iam-roles-for-cloudwatch-agent-roles), and [AWS X-Ray](https://docs.aws.amazon.com/xray/latest/devguide/security_iam_service-with-iam.html#xray-permissions-aws)
  - [Elastic IP](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-eips.html) (optional)
  - [gp3 or gp2](https://aws.amazon.com/ebs/general-purpose/) EBS volume type
  - [AWS Backup](https://aws.amazon.com/backup/) data protection (optional)
- Installed applications
  - [AWS CLI v2](https://aws.amazon.com/cli/) with [partial mode](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-parameters-prompting.html#cli-usage-auto-prompt-modes) [auto-prompt](https://docs.aws.amazon.com/cli/latest/userguide/cli-usage-parameters-prompting.html) 
  - [Amazon CloudWatch agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
  - [Certbot](https://certbot.eff.org/) with [Amazon Route 53](https://aws.amazon.com/route53/) [DNS challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge) support
  - [Docker Engine](https://docs.docker.com/engine/) also known as Docker CE (optional: Windows and Linux)
- Network and Content Delivery
  - [Amazon CloudFront](https://aws.amazon.com/cloudfront/) for web server (optional)
  - [AWS Global Accelerator](https://aws.amazon.com/global-accelerator/) network acceleration for DCV (optional)


### Demo

https://github.com/user-attachments/assets/16be5a5e-a347-40bc-85cc-22ce3f0995f8


https://github.com/user-attachments/assets/7314faf6-a267-4d1f-ad58-1814a605f355



## Deployment
See [cfn](cfn) section for deployment instructions.


### Other deployment options
The official [DCV site](https://www.amazondcv.com/) provides a [CloudFormation template](https://www.amazondcv.com/cloudformation.html) that allows the deployment of EC2 instances with DCV pre-installed and fully configured for internal testing. Refer to [Announcing updates to NICE DCV AWS CloudFormation Templates](https://aws.amazon.com/blogs/desktop-and-application-streaming/announcing-updates-to-nice-dcv-aws-cloudformation-templates/) for information.

To include DCV in your [EC2 Image Builder pipeline](https://docs.aws.amazon.com/imagebuilder/latest/userguide/manage-pipelines.html), refer to [Announcing the NICE DCV Amazon-managed component for EC2 Image Builder](https://aws.amazon.com/blogs/desktop-and-application-streaming/announcing-the-nice-dcv-amazon-managed-component-for-ec2-image-builder/).

For manual installation instructions, refer to [Amazon DCV Administrator Guide](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing.html).

### re:Post articles

DCV installation scripts are available from the following [re:Post](https://repost.aws/) community articles:

- [Install GUI (graphical desktop) on Amazon EC2 instances running Amazon Linux 2023 (AL2023)](https://repost.aws/articles/ARq0LbVvRwTRukVpS6Zt1uZw/install-gui-graphical-desktop-on-amazon-ec2-instances-running-amazon-linux-2023-al2023)
- [Install GUI (graphical desktop) on Amazon EC2 instances running Amazon Linux 2 (AL2)](https://repost.aws/articles/ARuqicSphdQ8-GiwZC2-QOXg/install-gui-graphical-desktop-on-amazon-ec2-instances-running-amazon-linux-2-al2)
- [Install GUI (graphical desktop) on Amazon EC2 instances running RHEL/Rocky Linux 8/9](https://repost.aws/articles/AR4Nbl3SxTSIW3WpFSUJhzXg/install-gui-graphical-desktop-on-amazon-ec2-instances-running-rhel-rocky-linux-8-9)
- [Install GUI (graphical desktop) on Amazon EC2 instances running SUSE Linux Enterprise Server 15 (SLES 15)](https://repost.aws/articles/ARGF6bVA19QC6IVcaUy-69Ag/install-gui-graphical-desktop-on-amazon-ec2-instances-running-suse-linux-enterprise-server-15-sles-15)
- [Install GUI (graphical desktop) on Amazon EC2 instances running Ubuntu Linux](https://repost.aws/articles/ARJtZxRiOURwWI2qSWjl4AaQ/install-gui-graphical-desktop-on-amazon-ec2-instances-running-ubuntu-linux)

To build a Deep Learning Desktop with [AWS Deep Learning AMI](https://aws.amazon.com/ai/machine-learning/amis/)

- [Deep Learning graphical desktop on Amazon Linux 2023 (AL2023) with AWS Deep Learning AMI (DLAMI)](https://repost.aws/articles/ARpObQqWDSTFaHjaBIhddL2Q/deep-learning-graphical-desktop-on-amazon-linux-2023-al2023-with-aws-deep-learning-ami-dlami)
- [Deep Learning graphical desktop on Ubuntu Linux with AWS Deep Learning AMI (DLAMI)](https://repost.aws/articles/AR6RrDeUL1Tq6R8TgDs59iEA/deep-learning-graphical-desktop-on-ubuntu-linux-with-aws-deep-learning-ami-dlami)

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

## Notice
Usage indicates acceptance of [DCV EULA](https://www.amazondcv.com/eula.html) and license agreements of all software that is installed on the EC2 instance. Some operating systems *are not supported* by DCV.  Refer to [documentation site](https://docs.aws.amazon.com/dcv/latest/adminguide/servers.html#requirements) for information.


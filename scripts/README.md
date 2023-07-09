## Description
[User data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-console) scripts to install NICE DCV server for various distributions. 

Do assign [EC2 instance profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html) with S3 access to [DCV-license](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-license.html#setting-up-license-ec2) and [AmazonSSMManagedInstanceCore](https://aws.amazon.com/blogs/mt/applying-managed-instance-policy-best-practices/) role. Security group should allow inbound TCP and UDP ports 8443.
You can use [template.yaml](template.yaml) CloudFormation file to create EC2 instance profile and security group.

You will also need to increase EBS volume size (to 10 GB or more) in order to install graphical desktop.

[CloudFormation templates](../cfn/) are recommended though as they provide more functionality. 

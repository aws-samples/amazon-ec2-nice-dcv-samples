## Description
[User data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-console) scripts to install NICE DCV server. 

Do assign [EC2 instance profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html) for [DCV licensing](https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-license.html#setting-up-license-ec2). Security group should allow inbound TCP and UDP ports 8443 for NICE DCV server.

You will need to increase EBS volume size (to 10 GB or more) in order to install graphical desktop.

[CloudFormation templates](../cfn/) are recommended as they provide more functionality. 

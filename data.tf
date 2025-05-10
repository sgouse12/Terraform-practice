data "aws_ami" "ami" {
  most_recent = true
  owners      = ["979382823631"]

}

aws ec2 describe-images --region ap-south-1 --filters "Name=architecture,Values=x86_64" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" --query "Images[*].[ImageId,OwnerId]" --output table

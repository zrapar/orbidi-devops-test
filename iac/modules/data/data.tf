# Retrieve the most recent Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true # Always fetch the latest version of the AMI

  # Filter AMIs by name
  filter {
    name   = "name"
    values = ["al2023-ami-*"] # Only include Amazon Linux 2023 images
  }

  # Filter AMIs by root device type
  filter {
    name   = "root-device-type"
    values = ["ebs"] # Use EBS-backed AMIs
  }

  # Filter AMIs by virtualization type
  filter {
    name   = "virtualization-type"
    values = ["hvm"] # Hardware virtualization
  }

  # Filter AMIs by architecture
  filter {
    name   = "architecture"
    values = ["x86_64"] # 64-bit architecture
  }

  owners = ["amazon"] # Owned by Amazon
}
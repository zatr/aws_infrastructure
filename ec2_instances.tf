module "aws_tools" {
  source          = "./ec2_instances/codedeploy_instance"
  # Ubuntu Server 20.04 LTS
  ami             = "ami-04505e74c0741db8d"
  instance_type   = "t2.micro"
  tag_name        = "aws_tools"
  tag_environment = "dev"
}

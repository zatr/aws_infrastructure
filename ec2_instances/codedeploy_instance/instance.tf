resource "aws_instance" "codedeploy_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  user_data     = "install.sh"
  tags          = {
    Name        = var.tag_name
    Environment = var.tag_environment
  }
}

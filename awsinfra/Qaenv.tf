#Creating Instance for qa Environment
resource "aws_instance" "MyInsqa" {
  ami                           = "ami-0149b2da6ceec4bb0"  
  associate_public_ip_address   = "false"
  instance_type                 = "t2.micro"
  availability_zone             = "us-east-1a"
  key_name                      = "My_TF_Key"
  security_groups               = ["${aws_security_group.websg.id}"]
  subnet_id                     = aws_subnet.subnets[0].id
  tags = {
    Name                        = "Qa_TF"
  }
}
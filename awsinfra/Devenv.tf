#Creating Instance for dev environment
resource "aws_instance" "MyIns" {
  ami                           = "ami-0149b2da6ceec4bb0"  
  associate_public_ip_address   = "true"
  instance_type                 = "t2.micro"
  availability_zone             = "us-east-1a"
  key_name                      = "My_TF_Key"
  security_groups               = ["${aws_security_group.websg.id}"]
  subnet_id                     = aws_subnet.subnets[0].id
  tags = {
    Name                        = "Dev_TF"
  }
}
resource "null_resource" "forprovising" {
  triggers = {
        "execute" = var.increment_execute
    }
  connection{
    type          = "ssh"
    host          =  aws_instance.MyIns.public_ip_address
  }
  rovisioner "remote-exec"  {
    inline=[
        "#!/bin/bash",
        "sudo apt update",
        "sudo apt install nginx -y"
    ]
  }
}
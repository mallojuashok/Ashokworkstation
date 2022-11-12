
# lets try to define the resource for the vpc
resource "aws_vpc" "myvpc" {
    cidr_block = var.vpc_cidr_range

    tags = {
      "Name" = "from-tf"
    }

}
# lets create web subnet
resource "aws_subnet" "subnets" {
  count                 = length(var.subnet_name_tags)
    vpc_id              = aws_vpc.myvpc.id
    cidr_block          = cidrsubnet(var.vpc_cidr_range,8,count.index)
    availability_zone   = format("${var.target_region}%s",count.index%2==0?"a":"b")

    tags                = {
      "Name"            = var.subnet_name_tags[count.index]
    }

}
# Creating Security group
resource "aws_security_group" "websg" {
    vpc_id             = aws_vpc.myvpc.id
    description        = "To Create Security Group"
    
    ingress{
      from_port        = local.ssh_port
      to_port          = local.ssh_port
      protocol         =local.any_tcp
      cidr_blocks      =[local.any_where]
    }
    ingress{
      from_port        = local.http_port
      to_port          = local.http_port
      protocol         = local.any_tcp
      cidr_blocks      =[local.any_where]
    }
    
    egress {
      from_port        = local.all_ports
      to_port          = local.all_ports
      protocol         = local.any_protocol
      cidr_blocks      =[local.any_where]
      ipv6_cidr_blocks = [local.any_ipv6]
   }
   tags                ={
    "Name"             ="Web Security"
   }
}
# Creating Security group
resource "aws_security_group" "Appsg" {
    vpc_id             = aws_vpc.myvpc.id
    description        = "To Create Security Group"
    
    ingress{
      from_port        = local.ssh_port
      to_port          = local.ssh_port
      protocol         =local.any_tcp
      cidr_blocks      =[local.any_where]
    }
    ingress{
      from_port        = local.app_port
      to_port          = local.app_port
      protocol         =local.any_tcp
      cidr_blocks      =[var.vpc_cidr_range]
    }
    
    egress {
      from_port        = local.all_ports
      to_port          = local.all_ports
      protocol         = local.any_protocol
      cidr_blocks      =[local.any_where]
      ipv6_cidr_blocks = [local.any_ipv6]
   }
   tags                ={
    "Name"             ="App Security"
   }
}
#Creating Internetgateway
resource "aws_internet_gateway" "igw" {
        vpc_id          = aws_vpc.myvpc.id
        tags            ={
          Name          = "Igw_tf"
        }
  
}
#Craeting Route public
resource "aws_route_table" "publicrt" {
    vpc_id              = aws_vpc.myvpc.id
   route {
       cidr_block       = local.any_where
       gateway_id       = aws_internet_gateway.igw.id
   }
    tags                = {
    "Name"              ="Public Rt"
   }
}
#Creating Elastic Ip
resource "aws_eip" "Myeip" {
  vpc                           = true
  #instance                      = aws_instance.MyInsqa.id
    #depends_on                    = [aws_internet_gateway.igw]
  
}
#Creating Nat Gateway
resource "aws_nat_gateway" "My_nat" {
    allocation_id       = aws_eip.Myeip.id
    subnet_id           = aws_subnet.subnets[0].id
}

#Craeting Route private
resource "aws_route_table" "pvtrt" {
    vpc_id              = aws_vpc.myvpc.id
    route {
       cidr_block       = local.any_where
       nat_gateway_id   = aws_nat_gateway.My_nat.id
    }
    tags                = {
    "Name"              = "Private Rt"
   }
}
# Creating Route Association
resource "aws_route_table_association" "Association" {
    count               = length(aws_subnet.subnets)
    subnet_id           = aws_subnet.subnets[count.index].id
    route_table_id      = count.index < 1 ?aws_route_table.publicrt.id : aws_route_table.pvtrt.id
  
}

#resource "aws_route_table_association" "Association" {
   
 #   subnet_id           = aws_subnet.subnets[0].id
 #   route_table_id      = aws_route_table.publicrt.id
  
#}
#resource "aws_route_table_association" "pvtAssociation" {
   
 #   subnet_id           = aws_subnet.subnets[1].id
 #   route_table_id      = aws_route_table.pvtrt.id
  
#}
#Creating Key pair
resource "aws_key_pair" "ssh_key" {
  key_name              = "My_TF_Key"
  public_key            = file("C:/Users/Aadrik/.ssh/id_rsa.pub")
  
}

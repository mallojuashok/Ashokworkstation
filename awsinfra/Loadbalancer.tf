# Creating Network load balancer
resource "aws_lb" "my_loadlb" {
    name                         = "networkload"
    internal                     = false
    load_balancer_type           = "network"
    subnets                      = [aws_subnet.subnets[0].id]
    ip_address_type              = "ipv4"
    enable_deletion_protection   = false
}

# Creating Target group for load balancer
resource "aws_lb_target_group" "awstgt" {
    name                    = "tgtgroup"
    port                    = 80
    protocol                = "TCP"
    target_type             = "instance"
    ip_address_type         = "ipv4"
    vpc_id                  = aws_vpc.myvpc.id
    health_check {
       port                 = 80
       protocol             = "TCP"
       healthy_threshold    = 3
       interval             = 10
    }
}

# Creating Listner Group
resource "aws_lb_listener" "awslistener" {
    load_balancer_arn       = aws_lb.my_loadlb.arn
    port                    = 80
    protocol                = "TCP"
    default_action {
      type                  = "forward"
      target_group_arn      = aws_lb_target_group.awstgt.arn
    }
}

# target_group_attachment
resource "aws_lb_target_group_attachment" "attach" {
    target_group_arn        = aws_lb_target_group.awstgt.arn
    target_id               = aws_instance.MyInsqa.id
    port                    = 80
  
}

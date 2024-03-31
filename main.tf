resource "aws_vpc" "ashvpc" {
  cidr_block = var.vpc

}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.ashvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true


}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.ashvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true


}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ashvpc.id

}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.ashvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "rt1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route.id

}

resource "aws_route_table_association" "rt2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route.id

}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.ashvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "ssh from vpc"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "webSg"
  }

}
resource "aws_s3_bucket" "example" {
  bucket = "ash2024terraformbucket"

}

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID" 
    type = "S"
  }
}


resource "aws_instance" "ashinstance1" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.webSg.id]
  user_data              = base64encode(file("userdata1.sh"))



}

resource "aws_instance" "ashinstance2" {
  ami                    = "ami-080e1f13689e07408"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.webSg.id]
  user_data              = base64encode(file("userdata.sh"))

}

resource "aws_lb" "alb" {
  name               = "ash-loadb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webSg.id]
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

}

resource "aws_lb_target_group" "tg" {
  name     = "ash-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ashvpc.id

  health_check {
    path = "/"
    port = "traffic-port"

  }

}

resource "aws_lb_target_group_attachment" "tga1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ashinstance1.id
  port             = 80

}

resource "aws_lb_target_group_attachment" "tga2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.ashinstance2.id
  port             = 80

}

resource "aws_lb_listener" "ashlistener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }

}

output "loadbalancerdns" {
  value = aws_lb.alb.dns_name

}

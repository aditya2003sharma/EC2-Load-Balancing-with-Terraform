resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}


resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}


resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "sub1_association" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "sub2_association" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.myrt.id
}


resource "aws_security_group" "my_sg" {
  name   = "my_sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
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
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "aditya-terraform-2026-projectaws"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_instance" "instance_1" {
  ami             = "ami-091138d0f0d41ff90"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.my_sg.id]
  subnet_id       = aws_subnet.sub1.id
  user_data       = base64encode(file("userdata.sh"))
}

resource "aws_instance" "instance_2" {
  ami             = "ami-091138d0f0d41ff90"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.my_sg.id]
  subnet_id       = aws_subnet.sub2.id
  user_data       = base64encode(file("userdata1.sh"))


}

resource "aws_lb_target_group" "tg" {
  name     = "terraform-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id


  health_check {
    path = "/"
    port = "traffic-port"
  }
}

# ---------------- Application Load Balancer ----------------

resource "aws_lb" "alb" {
  name               = "terraform-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id]

  subnets = [
    aws_subnet.sub1.id,
    aws_subnet.sub2.id
  ]

  tags = {
    Name = "terraform-alb"
  }
}

# ---------------- Listener ----------------

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}


resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.instance_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.instance_2.id
  port             = 80
}

# ---------------- Output ----------------

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
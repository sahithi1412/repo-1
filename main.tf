resource "aws_instance" "tf-sg1" {
  ami           = "ami-0862be96e41dcbf74"
  instance_type = "t2.micro"
  key_name = "sahithi key"
vpc_security_group_ids = [aws_security_group.allow_tls.id]
subnet_id = aws_subnet.pub-2.id
  user_data = "${file("File.sh")}"

  tags = {
    Name = "tf-sg1"
  }
}


resource "aws_instance" "tf-sg2" {
  ami           = "ami-0862be96e41dcbf74"
  instance_type = "t2.micro"
  key_name = "sahithi key"
vpc_security_group_ids = [aws_security_group.allow_tls.id]
subnet_id = aws_subnet.pub-2.id
  user_data = "${file("File.sh")}"

  tags = {
    Name = "tf-sg2"
  }
}






resource "aws_security_group" "allow_tls" {
  name        = "sahithi-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc-sg.id


ingress  {
     from_port        = 22
     to_port          = 22
     protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
}

ingress  {
     from_port        = 80
     to_port          = 80
     protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "sahithi-sg"
  }
}


resource "aws_lb" "lb-sg" {
  name               = "lb-sg"
  load_balancer_type = "application"
  subnets = [aws_subnet.pvt-1.id, aws_subnet.pub-1.id]
}

resource "aws_security_group" "lb_sg" {
  name = "lb-sg"
  vpc_id = aws_vpc.vpc-sg.id
  # Allow inbound HTTP requests
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
    Name = "lb-sg"
  }
}


resource "aws_lb_target_group" "lb_tg-sg" {
  name        = "lb-tg-sg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-sg.id
}

resource "aws_lb_target_group_attachment" "lb_tg-sg-attach1" {
  target_group_arn = aws_lb_target_group.lb_tg-sg.arn
  target_id        = aws_instance.tf-sg1.id
  port             = 80
  depends_on = [ aws_instance.tf-sg1 ]
}
resource "aws_lb_target_group_attachment" "lb_tg-sg-attach2" {
  target_group_arn = aws_lb_target_group.lb_tg-sg.arn
  target_id        = aws_instance.tf-sg2.id
  port             = 80
  depends_on = [ aws_instance.tf-sg2 ]
}

resource "aws_lb_listener" "tg-aws_lb_listener" {
  load_balancer_arn = aws_lb.lb-sg.arn
  port              = "80"
  protocol          = "HTTP"
  

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_tg-sg.id}"
  }
}

resource "aws_db_instance" "rds" {
  db_subnet_group_name = aws_db_subnet_group.rds-2.id 
  allocated_storage    = 8
  db_name              = "rds"
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t2.micro"
  username             = "sahithi"
  password             = "sahithi14"
  skip_final_snapshot  = true

}


resource "aws_db_subnet_group" "rds-2" {
  name = "rds_2"
  subnet_ids = [aws_subnet.pvt-1.id, aws_subnet.pub-1.id]

  tags = {
    name = "rds_2"
  }
}
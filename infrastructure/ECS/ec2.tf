# Bastion host
resource "aws_instance" "bastion" {
  ami                         = "ami-0453898e98046c639"
  instance_type               = var.bastion-instance-type
  subnet_id                   = aws_subnet.public_1.id
  security_groups             = [aws_security_group.bastion.id]
  key_name                    = "EC2-key-pair"
  associate_public_ip_address = true

  tags = {
    Name = "ECS-Bastion-host"
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "ECS-bastion-sg"
  }
}

resource "aws_security_group" "webserver_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.bastion.id]
    protocol        = "tcp"
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
  }

  tags = {
    Name = "webserver_sg",
    managedBy = "Terraform"
  }
}

# launch configuration
resource "aws_launch_configuration" "webserver_launch_config" {
  name_prefix          = "ecs-webserver"
  image_id             = "ami-0453898e98046c639"
  instance_type        = var.webserver-instance-type
  key_name             = "EC2-key-pair"
  security_groups      = [aws_security_group.webserver_sg.id]
  user_data = templatefile("userdata.tpl", {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
  })
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_ecs_cluster.ecs_cluster]
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                 = "ecs-asg"
  max_size             = 4
  min_size             = 1
  desired_capacity     = 2
  force_delete         = true
  depends_on           = [aws_lb.alb]
  target_group_arns    = [aws_lb_target_group.TG.arn]
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.webserver_launch_config.name
  vpc_zone_identifier  = [aws_subnet.pvt_1.id, aws_subnet.pvt_2.id]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "ecs-asg-instance"
  }
}

resource "aws_lb_target_group" "TG" {
  name       = "ecs-target-group"
  depends_on = [aws_vpc.main]
  port       = var.container-port
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id

  health_check {
    interval            = 90
    path                = "/"
    port                = var.container-port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200,202"
  }

  tags = {
    Name = "ecs-target-group",
    managedBy = "Terraform"
  }
}
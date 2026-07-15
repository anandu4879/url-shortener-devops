data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "monitoring" {
  name_prefix = "${var.name_prefix}-monitoring-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-monitoring-sg" }
}

resource "aws_iam_role" "monitoring_role" {
  name = "${var.name_prefix}-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "monitoring_ssm" {
  role       = aws_iam_role.monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Needed for Prometheus's EC2 service discovery to query running instances
resource "aws_iam_role_policy" "monitoring_ec2_describe" {
  name = "${var.name_prefix}-monitoring-ec2-describe"
  role = aws_iam_role.monitoring_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ec2:DescribeInstances"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "monitoring_profile" {
  name = "${var.name_prefix}-monitoring-profile"
  role = aws_iam_role.monitoring_role.name
}

resource "aws_instance" "monitoring" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.monitoring.id]
  iam_instance_profile   = aws_iam_instance_profile.monitoring_profile.name

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    aws_region = var.aws_region
  }))

  tags = { Name = "${var.name_prefix}-monitoring" }
}
resource "aws_instance" "monitoring" {
  ami                          = data.aws_ami.amazon_linux.id
  instance_type                = var.instance_type
  subnet_id                    = var.private_subnet_ids[0]
  vpc_security_group_ids       = [aws_security_group.monitoring.id]
  iam_instance_profile         = aws_iam_instance_profile.monitoring_profile.name
  user_data_replace_on_change  = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tpl", {
    aws_region = var.aws_region
  }))

  tags = { Name = "${var.name_prefix}-monitoring" }
}
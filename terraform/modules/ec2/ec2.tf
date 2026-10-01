


resource "aws_security_group" "this" {
  name        = "${var.env}-${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  # Dynamically generate ingress rules based on parent inputs
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.name}-sg"
  }
}

# resource to create ec2 instance
resource "aws_instance" "my_ec2_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [aws_security_group.this.id]
  iam_instance_profile = aws_iam_instance_profile.this.name


    root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    delete_on_termination = true
  }

  tags = {
    environment = var.env
    Name = "${var.env}-${var.instance_name}"
  }
}

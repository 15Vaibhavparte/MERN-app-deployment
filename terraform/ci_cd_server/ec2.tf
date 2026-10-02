

# 1. Fetch the Default VPC and its Internet Gateway
data "aws_vpc" "default" {
  default = true
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# 2. Create the Custom Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = var.public_subnet_cidr # e.g., "172.31.100.0/24"
  availability_zone       = var.public_subnet_az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-subnet-cicd"
  }
}

# 3. Create and Associate the Route Table
resource "aws_route_table" "public_rt_cicd" {
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.default.id
  }

  tags = {
    Name = "${var.env}-public-rt-cicd"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt_cicd.id
}

# 4. Deploy the CI/CD Server
module "ci_cd_server" {
  source = "/home/lenovo/terraform_demo/terraform-MERN/terraform/modules/ec2" # Fixed: Restored to root-relative path

  env           = var.env
  name          = "ci_cd_server"
  instance_name = "ci_cd_server"

  vpc_id        = data.aws_vpc.default.id
  subnet_id     = aws_subnet.public_subnet.id
  instance_type = var.instance_type

  root_volume_size = 25
  root_volume_type = "gp3"

  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]

  ingress_rules = [
    {
      description = "Allow SSH from anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow Jenkins Web UI"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow SonarQube Web UI"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Provide the user data script
  user_data = templatefile("${path.module}/tools.sh", {})

  tags = {
    Name = "${var.env}-ci_cd_server"
  }
}
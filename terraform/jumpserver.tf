
module "jumpserver" {
  source = "../terraform/modules/ec2" 

  env  = var.env
  name = "jumpserver"
  instance_name = "jumpserver"

  # Link directly to the VPC module outputs
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0] # Place in the first public subnet
  instance_type = "t3.medium"

#storage configuration
    root_volume_size = 15
    root_volume_type = "gp3"

  # Attach the SSM policy so you can access it securely without SSH keys
  iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  # Inject the Jump Server specific port rules
  ingress_rules = [
    {
      description = "Allow SSH from anywhere (or restrict to your home IP)"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
    }
  ] 
}



variable "env" { type = string }
variable "name" { type = string }
variable "instance_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "instance_type" { type = string }
variable "root_volume_size" { type = number }
variable "root_volume_type" { type = string }
# Dynamic IAM Policies
variable "iam_policy_arns" { type = list(string) }

# Dynamic Security Group Rules
variable "ingress_rules" {
  description = "List of ingress rules to apply to the instance's security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
# variables.tf

variable "env"                   {}
variable "public_subnet_cidr"    {}
variable "public_subnet_az"      {}
variable "instance_type"         { default = "t3.medium" }
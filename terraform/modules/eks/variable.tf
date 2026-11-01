#eks variables

variable "region"                    {default = "" }
variable "vpc_id"                    { default = "" }
variable "cluster-name"              { default = "" }
variable "cluster-version"           { type = string }
variable "enable_alb_controller"     { 
    type = bool 
    default = true 
}
variable "addons"                    {}
variable "private_subnet_ids"        {}
variable "eks_cluster_sg_id"         {}
variable "desired_capacity_on_demand" {}
variable "min_capacity_on_demand"     {}
variable "max_capacity_on_demand"     {}
variable "ondemand_instance_types"     {}

variable "desired_capacity_spot" {}
variable "min_capacity_spot"     {}
variable "max_capacity_spot"     {}
variable "spot_instance_types"     {}
variable "env" {}

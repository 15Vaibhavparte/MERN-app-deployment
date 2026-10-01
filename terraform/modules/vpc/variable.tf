# variables.tf
variable "vpc-name"               {}
variable "env"                    {}
variable "cidr-block"             { default = "10.0.0.0/16" }
variable "igw-name"               {}

variable "pub-subnet-count"       {}
variable "pub-cidr-block"         {}
variable "pub-availability-zone"  {}
variable "pub-sub-name"           {}
variable "cluster-name"           {}
variable "pri-subnet-count"       {}
variable "pri-cidr-block"         {}
variable "pri-availability-zone"  {}
variable "pri-sub-name"           {}

variable "public-rt-name"         {}
variable "private-rt-name"        {}

variable "eip-name"               {}
variable "ngw-name"               {}

variable "eks-sg"                 {}
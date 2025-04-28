variable "vpc_id" {
  description = "EC2 instance vpc"
  type        = string
}

variable "private_route_table_ids" {
  description = "Private route table IDs"
  type        = list
}

variable "name" {
  description = "EC2 instance name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_key" {
  description = "EC2 instance ssh key"
  type        = string
}

variable "instance_subnet" {
  description = "EC2 instance subnet"
  type        = string
}

variable "vpc_cidr_block" {
  description = "EC2 nat CIDR"
  type        = string
}

variable "public_ports" {
  type = map(number)
  default = {
    SSH  = 22
  }
}

variable "tags" {
  type = map(string)
  description = "Tags"
  default = {}
}

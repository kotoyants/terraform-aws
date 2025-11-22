# terraform-aws
### Terrafrorm
```
module "nat" {
  source = "./path/to/my_module"

  input_variable_1 = "value_1"
  input_variable_2 = var.some_variable_from_root
}
```
### Terrugrunt
```
terraform {
  source = "github.com/kotoyants/terraform-aws/bastion"
}

dependency "vpc" {
  config_path = "../aws-vpc"
  mock_outputs = {
    vpc_id                  = "vpc-1111"
    public_subnets          = ["subnet-1111"]
    private_route_table_ids = ["rtb-1111"]
  }
}

dependency "eip" {
  config_path = "../aws-ec2-eip"
  mock_outputs = {
    eip_ids = {
      bastion = "1111"
    }
  }
}

dependency "key" {
  config_path = "../aws-ec2-key"
}

inputs = {
  name                    = "project-nat"
  instance_key            = "user"
  vpc_id                  = dependency.vpc.outputs.vpc_id
  instance_subnet         = dependency.vpc.outputs.public_subnets[0]
  vpc_cidr_block          = include.env.locals.vpc_cidr
  private_route_table_ids = dependency.vpc.outputs.private_route_table_ids
  eip_id                  = dependency.eip.outputs.eip_ids.bastion
  tags                    = local.tags
    public_ports          = {
    HTTP  = 80
    HTTPS = 443
    RDP   = 13389
    SSH   = 10022
  }
}

```


terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws"{
    region     = "us-west-2"
    access_key = var.access_key
    secret_key = var.secret_key
}

locals {
  extra_tag = "extra-tag"
}
resource "aws_instance" "example" {
  for_each = { for i, subnet in module.vpc.public_subnets : i => subnet }

    ami           = "ami-0663b059c6536cac8"
    instance_type = "t2.micro" 
    subnet_id              = each.value
    vpc_security_group_ids = [module.terraform-sg.security_group_id] 
    associate_public_ip_address = true 

     tags = {
    ExtraTag = local.extra_tag
    Name     = "EC2-${each.key}"
  }
}

resource "aws_cloudwatch_log_group" "ec2_log_group" {
  for_each = var.service_name


  tags = {
    Environment = "test"
    Service     = each.key
  }
  lifecycle {
    create_before_destroy = true
  }
}

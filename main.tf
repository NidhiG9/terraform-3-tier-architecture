provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "3-tier"
  subnet_id = lookup(module.vpc.sub-output, "pub-1", null)
  security_groups = [lookup(module.elb-sg.output-sg, "elb_security_group", null).id]


  tags = {
    Name = "jump-sever"
  }
}

module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  pub_subnet = {
    pub-1 = {
      cidr_block = "10.0.0.0/18"
      availability_zone = "us-east-1a"
    },
    pub-2 = {
      cidr_block = "10.0.64.0/18"
      availability_zone = "us-east-1b"
    }
  }
 priv_subnet = {
    pvt-1 = {
      cidr_block = "10.0.128.0/18"
      availability_zone = "us-east-1a" 
    },
    pvt-2 = {
      cidr_block = "10.0.192.0/18"
      availability_zone = "us-east-1b"
    }
  }

  nat-gateway = {
    nat-1 = {
      allocation_id = lookup(module.vpc.eip-output, "eip-1",null)
      subnet_id = lookup(module.vpc.sub-output, "pub-1", null)
    }
    nat-2 = {
      allocation_id = lookup(module.vpc.eip-output, "eip-2",null)
      subnet_id = lookup(module.vpc.sub-output, "pub-2", null)
    }
  }

eip = {
  eip-1={}
  eip-2={}
}

priv_subnet_rt = {
  priv_rt-1 = {
     gateway_id = lookup(module.vpc.nat-output,"nat-1", null)
  }
  priv_rt-2 = {
     gateway_id = lookup(module.vpc.nat-output, "nat-2", null)
  }
 

}


private-rt-association = {
    association-1 = {
      route_table_id = lookup(module.vpc.rt-output, "priv_rt-1", null )
      subnet_id = lookup(module.vpc.sub-pvt-output, "pvt-1", null)
      }
      association-2 = {
      route_table_id = lookup(module.vpc.rt-output, "priv_rt-2", null )
      subnet_id = lookup(module.vpc.sub-pvt-output, "pvt-2", null)
  }
}


}

module "elb-sg" {                                                # public-load-balancer-sg
  source = "./modules/sg"
  security_group = {
    "elb_security_group" = {
      name = "pub-elb-sg"
      vpc_id      = module.vpc.vpc-output.id
      ingress_rules = [
        {
          from_port = 80
          to_port  = 80
          cidr_blocks = ["0.0.0.0/0"]
          protocol = "TCP"
          security_groups = null
        },
         {
          from_port = 22
          to_port  = 22
          cidr_blocks = ["0.0.0.0/0"]
          protocol = "TCP"
          security_groups = null
        }
        
      ]

      
      
    }
  }
  
}
module "sg" {                                            #web-server-sg
  source = "./modules/sg"
   security_group = {
    "web-server" = {
      name        = "web-server"
      vpc_id      = module.vpc.vpc-output.id
      ingress_rules = [
        {
          from_port = 80
          to_port  = 80
          cidr_blocks = null
          protocol = "TCP"
          security_groups = [lookup(module.elb-sg.output-sg, "elb_security_group", null).id]
        },
       {
          from_port = 22
          to_port  = 22
          cidr_blocks = ["0.0.0.0/0"]
          protocol = "TCP"
          security_groups = null
        }
      ]
    }

  }
}

module "priv-elb" {                                                             #internal-loadbalancer-sg
  source = "./modules/sg"
  security_group = {
    "private-elb" = {
      name = "internal-elb"
      vpc_id      = module.vpc.vpc-output.id
       ingress_rules = [
        {
          from_port = 80
          to_port  = 80
          cidr_blocks = null
          protocol = "TCP"
          security_groups = [lookup(module.sg.output-sg, "web-server", null).id]
        }
      ]
      
    }
  }
  
}



   module "asg" {                                           #app-server-sg
    source = "./modules/sg"
    security_group = {
    "asg-sg" = {
      name        = "asg"
      vpc_id  = module.vpc.vpc-output.id
      ingress_rules = [
        {
        from_port = 8080
        to_port = 8080
        cidr_blocks = null
        protocol = "TCP"
        security_groups = [lookup(module.priv-elb.output-sg, "private-elb", null).id]
        },
        {
          from_port = 22
          to_port  = 22
          cidr_blocks = ["0.0.0.0/0"]
          protocol = "TCP"
          security_groups = null
        }

        
        
    ]
    }
   }
   }

    module "rds-sg" {                                           #rds-sg
    source = "./modules/sg" 
    security_group = {
    "rds" = {
      name        = "RDS"
      vpc_id      = module.vpc.vpc-output.id
      ingress_rules = [
        {
          from_port = 3306
          to_port  = 3306
          cidr_blocks = null
          protocol = "TCP"
          security_groups = [lookup(module.asg.output-sg,"asg-sg", null).id]
        }

      ]
    }
    
  }
 }

 module "elb" {
  source = "./modules/elb"
  public_elb_name = "elb-new"
  internal = false
  elb_type = "application"
  public_elb_subnet = [
  lookup(module.vpc.sub-output, "pub-1", null),
  lookup(module.vpc.sub-output, "pub-2", null)
]
  public_elb_sg =  [lookup(module.elb-sg.output-sg, "elb_security_group", null).id]
  elb_tg_name = "public-elb-tg"
  elb_public_port = 80
  elb_public_protocol = "HTTP"
  elb_public_vpc_id = module.vpc.vpc-output.id
  elb_tg_listener_port = 80
  elb_tg_listener = "HTTP"
     enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200-399"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 6
    unhealthy_threshold = 3

  private_elb_name = "elb-private"
  interal_elb = true
  elb_type_internal = "application"
  private_elb_sg = [lookup(module.priv-elb.output-sg, "private-elb", null).id]
  private_elb_subnet =  [
  lookup(module.vpc.sub-pvt-output, "pvt-1", null),
  lookup(module.vpc.sub-pvt-output, "pvt-2", null)
]
 private_tg_name = "private-internal-tg"
 private_tg_port = 8080
 private_tg_protocol = "HTTP"
 private_tg_vpc_id = module.vpc.vpc-output.id
 private_tg_listener_port = 80
 private_tg_listener_protocol = "HTTP"



}

module "asg-1" {
  source = "./modules/asg"
  elb = "web-server"
  web_asg_name ="web-asg"
  max_size = 3 
  min_size = 1 
  desired_capacity = 1
  healthcheck = 200 
  health_check_type =  "ELB"  
asg_subnets = [lookup(module.vpc.sub-pvt-output, "pvt-1", null),lookup(module.vpc.sub-pvt-output, "pvt-2", null)]
launch_template_sg = [lookup(module.sg.output-sg, "web-server", null).id]

  public_elb-tg_arn = module.elb.tg_public_output.arn 
  image = "ami-080e1f13689e07408"
  instance_type = "t2.micro"
  key_name = "3-tier"


  elb_internal_name = "app-asg"
  internal_max_size = 3
  internal_min_size = 1
  internal_desired_capacity = 1
  internal_health_check_grace_period = 300
  internal_health_check_type = "ELB"
  asg_subnet_internals = [lookup(module.vpc.sub-pvt-output, "pvt-1", null),lookup(module.vpc.sub-pvt-output, "pvt-2", null)]
  internal_launch_sg = [lookup(module.asg.output-sg,"asg-sg", null).id]
  private_key_pair = "3-tier"
  elb_internal_tg_arn = module.elb.elb_private_output.arn
  image_internal = "ami-080e1f13689e07408"
  instance_type_internal = "t2.micro"
  elb_internal-tg-arn = module.elb.tg_private_output.arn 

}

module "rds" {
    source = "./modules/rds"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    dbname =  "db1"
    username = "admin"
    password = "admin123"
    rds_availability_zone =  "us-east-1a"
    rds_security_group_id = [lookup(module.rds-sg.output-sg,"rds", null).id]
   publicly_accessible = false
   subnet_ids = [lookup(module.vpc.sub-pvt-output, "pvt-1", null),lookup(module.vpc.sub-pvt-output, "pvt-2", null)]

}

module "route53" {
  source = "./modules/route53"
  route53-vpc = module.vpc.vpc-output.id
  elb-dns = module.elb.elb_private_output.dns_name
  elb-hosted-zone-id = module.elb.elb_private_output.zone_id

  
}

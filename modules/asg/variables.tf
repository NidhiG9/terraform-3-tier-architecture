
variable "instance_type" {

}

variable "elb" {

}
variable "image" {

}

variable "elb_internal_name" {
  
}

variable "image_internal" {
  
}

variable "instance_type_internal" {
  
}

      


variable "asg_subnets" {

  
}

variable "public_elb-tg_arn" {
  
}

variable "elb_internal_tg_arn" {
  
}

variable "web_asg_name" {
  
}

variable "max_size" {
  
}

variable "min_size" {
  
}


variable "healthcheck" {
  
}


variable "asg_subnet_internals" {
}

variable "health_check_type" {
  
}

variable "desired_capacity" {
    type = number
  
}


variable "internal_max_size" {
  
}

variable "internal_min_size" {
  
}

variable "internal_desired_capacity" {
  
}

variable "internal_health_check_grace_period" {
  
}

variable "internal_health_check_type" {
  
}

variable "elb_internal-tg-arn" {
    type = any
  
}


variable "launch_template_sg" {
  
}

variable "internal_launch_sg" {
  
}

variable "key_name" {
  
}

variable "private_key_pair" {
  
}

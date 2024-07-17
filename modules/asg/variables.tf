variable "public_elb_name" {
  
}

variable "public_elb_sg" {
    type = list(string)
  
}

variable "public_elb_subnet" {
  
}

variable "elb_tg_name" {
  
}

variable "elb_public_port" {
  
}

variable "elb_public_protocol" {
  
}

variable "elb_public_vpc_id" {
  
}


variable "elb_tg_listener_port" {
  
}

variable "elb_tg_listener" {
  
}

variable "private_elb_name" {
  
}

variable "private_elb_sg" {
    type = any
  
}

variable "private_elb_subnet" {
    type = any
  
}

variable "private_tg_name" {
  
}

variable "private_tg_port" {
  
}

variable "private_tg_protocol" {
  
}

variable "private_tg_vpc_id" {
  
}


variable "private_tg_listener_port" {
  
}

variable "private_tg_listener_protocol" {
  
}




variable "internal" {
  
}

variable "elb_type" {
  
}

variable "interal_elb" {
  
}

variable "elb_type_internal" {
  
}

variable "enabled" {
  
}

variable "healthy_threshold" {
  
}

variable "interval" {
  
}

variable "matcher" {
  
}

variable "port" {
  
}

variable "protocol" {
  
}

variable "timeout" {
  
}

variable "unhealthy_threshold" {
  
}

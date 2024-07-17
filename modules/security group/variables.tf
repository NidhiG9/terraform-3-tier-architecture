variable "security_group" {
    type = map(object({
        name = string
        vpc_id = string
        ingress_rules=list(object({

            from_port = number
            to_port = number
            protocol = string
            cidr_blocks = list(string)
            security_groups = list(string)
        }))
    }))


  
}

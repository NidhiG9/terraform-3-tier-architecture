output "output-sg" {

    value = {for k,v in aws_security_group.sg: k => v}
  
}


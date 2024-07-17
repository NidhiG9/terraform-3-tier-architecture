output "elb_public_output" {
    value = aws_lb.public_elb
}

output "elb_private_output" {
    value = aws_lb.private_elb
  
}

# output "tagret_group_public" {
  
# }

output "tg_public_output" {
    value = aws_lb_target_group.public-tg
  
}

output "tg_private_output" {
    value = aws_lb_target_group.private_tg
  
}

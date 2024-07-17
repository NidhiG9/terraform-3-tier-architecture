output "vpc-output" {
    value = aws_vpc.vpc
}

output "sub-output" {
    value = {for k, v in aws_subnet.public:k=>v.id}
}

output "sub-pvt-output" {
    value = {for k, v in aws_subnet.private:k=>v.id}
  
}


output "eip-output" {
  value = {for k, v in aws_eip.eip:k=>v.id}
}

output "nat-output" {
    value = {for k, v in aws_nat_gateway.main:k=>v.id}
  
}

output "rt-output" {
    value = {for k, v in aws_route_table.priv-RT:k=>v.id}
  
}

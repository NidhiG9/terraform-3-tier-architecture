resource "aws_route53_zone" "private" {
  name = "example.com"


  vpc {
    vpc_id = var.route53-vpc
  }
}


resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.private.id
  name    = "example.com"
  type    = "A"
  

  alias {
    name                   = var.elb-dns 
    zone_id                = var.elb-hosted-zone-id 
    evaluate_target_health = true
  }
}

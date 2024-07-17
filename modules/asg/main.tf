resource "aws_launch_template" "elb_public" {
  name_prefix             = var.elb
  image_id                = var.image
  instance_type           = var.instance_type
  vpc_security_group_ids  = var.launch_template_sg
  key_name                = var.key_name

  tags = {
    Name = "web-server-3tier"
  }

  user_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install -y apache2
  sudo a2enmod proxy
  sudo a2enmod proxy_http
  sudo bash -c 'cat > /etc/apache2/sites-enabled/000-default.conf' << EOL
  <VirtualHost *:*>
      ProxyPreserveHost On
      ProxyPass / http://example.com
      ServerName localhost
  </VirtualHost>
  EOL
  sudo systemctl restart apache2
EOF
  )
}

resource "aws_autoscaling_group" "web-asg" {
  name                      = var.web_asg_name
  max_size                  = var.max_size
  min_size                  = var.min_size 
  health_check_grace_period = var.healthcheck
  health_check_type         = var.health_check_type 
  desired_capacity          = var.desired_capacity
   launch_template {
    id      = aws_launch_template.elb_public.id
    version = aws_launch_template.elb_public.latest_version
  }
  vpc_zone_identifier       = var.asg_subnets
  target_group_arns         = [var.public_elb-tg_arn]
}

resource "aws_launch_template" "elb_internal" {
  name_prefix   = var.elb_internal_name
  image_id      = var.image_internal
  instance_type = var.instance_type_internal
   vpc_security_group_ids = var.internal_launch_sg
   key_name = var.private_key_pair
   tags = {
    Name = "app-server-3tier"
  }
  
 user_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install openjdk-8-jdk -y
  sudo apt install tomcat9 -y
  sudo systemctl start tomcat9
  cd /var/lib/tomcat9/webapps/ROOT/
  rm -rf index.html
  wget https://github.com/AKSarav/SampleWebApp/raw/master/dist/SampleWebApp.war
  jar -xvf SampleWebApp.war
  systemctl restart tomcat9
  EOF
  ) 
}


resource "aws_autoscaling_group" "internal-asg" {
  name                      = "internal-asg"
  max_size                  = var.internal_max_size
  min_size                  = var.internal_min_size
  desired_capacity          = var.internal_desired_capacity
  health_check_grace_period = var.internal_health_check_grace_period
  health_check_type         = var.internal_health_check_type 
   launch_template {
    id      = aws_launch_template.elb_internal.id
    version = aws_launch_template.elb_internal.latest_version
  }
  vpc_zone_identifier       = var.asg_subnet_internals
  target_group_arns         = [var.elb_internal-tg-arn]
  
}






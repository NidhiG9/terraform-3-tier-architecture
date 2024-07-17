resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class 
  db_name              = var.dbname
  username             = var.username
  password             = var.password
  availability_zone    = var.rds_availability_zone
  vpc_security_group_ids = var.rds_security_group_id
  publicly_accessible = var.publicly_accessible
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  skip_final_snapshot  = true
  
  }

  resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group"
  subnet_ids = var.subnet_ids
}


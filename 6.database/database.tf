
resource "aws_db_subnet_group" "subnet_group_database" {
  name       = "tf_subnet_group_database"
  subnet_ids = var.private_subnets_id
}

resource "aws_db_instance" "database" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  db_name                = "postgres"
  username               = "postgres"
  password               = "postgres"
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.subnet_group_database.id
  vpc_security_group_ids = [var.sg_database_id]
  identifier             = "postgresdb"

}

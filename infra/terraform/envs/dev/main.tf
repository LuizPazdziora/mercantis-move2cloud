locals {
  common_tags = merge(var.common_tags, {
    Environment = var.environment
  })
}

module "network" {
  source = "../../modules/network"

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  common_tags              = local.common_tags
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  alb_ingress_cidrs    = var.alb_ingress_cidrs
  enable_https_ingress = var.enable_https_ingress
  app_port             = var.app_port
  db_port              = var.db_port
  ssh_allowed_cidrs    = var.ssh_allowed_cidrs
  common_tags          = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  private_db_subnet_ids = module.network.private_db_subnet_ids
  rds_security_group_id = module.security_groups.rds_security_group_id

  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_port                 = var.db_port
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_max_allocated_storage
  backup_retention_period = var.db_backup_retention_period
  multi_az                = var.db_multi_az
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection
  common_tags             = local.common_tags
}

module "ec2_docker" {
  source = "../../modules/ec2-docker"

  project_name      = var.project_name
  environment       = var.environment
  subnet_id         = module.network.private_app_subnet_ids[0]
  security_group_id = module.security_groups.ec2_app_security_group_id
  instance_type     = var.ec2_instance_type
  key_name          = var.ec2_key_name
  root_volume_size  = var.ec2_root_volume_size

  repository_url    = var.repository_url
  repository_branch = var.repository_branch
  db_host           = module.rds.rds_address
  db_port           = var.db_port
  db_name           = var.db_name
  db_user           = var.db_username
  db_password       = var.db_password
  allowed_origins   = var.allowed_origins
  common_tags       = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  target_instance_id    = module.ec2_docker.ec2_instance_id
  target_port           = var.app_port
  health_check_path     = var.health_check_path
  common_tags           = local.common_tags
}

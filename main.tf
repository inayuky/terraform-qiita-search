module "network" {
  source                    = "./modules/network"
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet0_cidr_block = var.public_subnet0_cidr_block
  public_subnet1_cidr_block = var.public_subnet1_cidr_block
}

module "https_sg" {
  source       = "./modules/security_group"
  name         = "https-sg"
  vpc_id       = module.network.vpc_id
  ingress_port = 443
}

module "http_redirect_sg" {
  source       = "./modules/security_group"
  name         = "http-redirect-sg"
  vpc_id       = module.network.vpc_id
  ingress_port = 80
}

module "fess_sg" {
  source       = "./modules/sg_from_sg"
  name         = "fess-sg"
  vpc_id       = module.network.vpc_id
  ingress_port = var.fess_port
  source_sg_id = module.https_sg.security_group_id
}

module "instance" {
  source           = "./modules/instance"
  instance_type    = var.instance_type
  sg_ids           = [module.fess_sg.security_group_id]
  subnet_id        = module.network.public_subnet0_id
  root_volume_size = var.root_volume_size
  root_volume_type = var.root_volume_type
}

module "log_bucket" {
  source = "./modules/log_bucket"
  name   = var.alb_name
}

module "domain" {
  source      = "./modules/domain"
  name        = var.domain_name
  lb_dns_name = module.alb.dns_name
  lb_zone_id  = module.alb.zone_id
}

data "aws_acm_certificate" "this" {
  domain = var.domain_name
}

module "alb" {
  source              = "./modules/lb"
  name                = var.alb_name
  subnet0_id          = module.network.public_subnet0_id
  subnet1_id          = module.network.public_subnet1_id
  log_bucket_id       = module.log_bucket.bucket_id
  https_sg_id         = module.https_sg.security_group_id
  http_redirect_sg_id = module.http_redirect_sg.security_group_id
  vpc_id              = module.network.vpc_id
  target_group_name   = var.target_group_name
  target_group_port   = var.fess_port
  acm_certificate_arn = data.aws_acm_certificate.this.arn
  instance_id         = module.instance.id
}

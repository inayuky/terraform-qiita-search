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

module "ssm_s3_role" {
  source     = "./modules/iam_role"
  name       = "ssm_s3"
  identifier = "ec2.amazonaws.com"
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "s3full" {
  name = "AmazonS3FullAccess"
}

data "aws_iam_policy" "cloudwatch" {
  name = "CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = module.ssm_s3_role.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_role_policy_attachment" "s3full" {
  role       = module.ssm_s3_role.name
  policy_arn = data.aws_iam_policy.s3full.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = module.ssm_s3_role.name
  policy_arn = data.aws_iam_policy.cloudwatch.arn
}

module "instance" {
  source           = "./modules/instance"
  instance_type    = var.instance_type
  sg_ids           = [module.fess_sg.security_group_id]
  subnet_id        = module.network.public_subnet0_id
  root_volume_size = var.root_volume_size
  root_volume_type = var.root_volume_type
  role_name        = module.ssm_s3_role.name
  instance_name    = var.domain_name
}

module "url_bucket" {
  source          = "./modules/url_bucket"
  name            = var.url_bucket_name
  vpc_id          = module.network.vpc_id
  route_table_ids = [module.network.route_table_id]
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

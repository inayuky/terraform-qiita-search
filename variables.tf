variable "vpc_cidr_block" {
  description = "VPCのCIDR"
}
variable "public_subnet0_cidr_block" {
  description = "パブリックサブネット0のCIDR"
}
variable "public_subnet1_cidr_block" {
  description = "パブリックサブネット1のCIDR(ALBはサブネットが２つ以上必須)"
}
variable "alb_name" {
  description = "ALBの名前"
}
variable "target_group_name" {
  description = "ターゲットグループの名前"
}
variable "domain_name" {
  description = "ドメイン名"
}
variable "instance_type" {
  description = "インスタンスタイプ"
}
variable "fess_port" {
  description = "Fessのポート番号"
}
variable "root_volume_size" {
  description = "ルートボリュームの容量"
}
variable "root_volume_type" {
  description = "ルートボリュームのタイプ"
}
variable "url_bucket_name" {
  description = "QiitaのURL格納用のバケット名"
}

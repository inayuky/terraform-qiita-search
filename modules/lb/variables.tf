variable "name" {
  description = "ALBの名前"
}
variable "subnet0_id" {
  description = "ALBを配備するサブネット0のID"
}
variable "subnet1_id" {
  description = "ALBを配備するサブネット1のID"
}
variable "log_bucket_id" {
  description = "ALBのログを格納するバケットのID"
}
variable "https_sg_id" {
  description = "HTTPS通信用のSGのID"
}
variable "http_redirect_sg_id" {
  description = "HTTPをHTTPSへリダイレクトするためのSGのID"
}
variable "vpc_id" {
  description = "VPCのID"
}
variable "target_group_name" {
  description = "ターゲットグループ名"
}
variable "target_group_port" {
  description = "ターゲットグループのポート番号(インスタンスがLISTENしているポート番号)"
}
variable "acm_certificate_arn" {
  description = "証明書のARN"
}
variable "instance_id" {
  description = "ALBがターゲットとするインスタンスのID"
}

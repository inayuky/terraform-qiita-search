variable "instance_type" {
  description = "インスタンスタイプ"
}
variable "root_volume_size" {
  description = "ルートボリュームの容量"
}
variable "root_volume_type" {
  description = "ルートボリュームのタイプ"
}
variable "sg_ids" {
  description = "インスタンスに設定するSG(複数可)"
}
variable "subnet_id" {
  description = "インスタンスが属するサブネット"
}

# SSMから最新のAMIを取得
data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "fess" {
  ami = data.aws_ssm_parameter.amzn2_ami.value

  instance_type = var.instance_type

  vpc_security_group_ids = var.sg_ids

  subnet_id = var.subnet_id

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  # fessのインストール
  user_data = file("${path.module}/install_fess.sh")

}

output "id" {
  value = aws_instance.fess.id
}

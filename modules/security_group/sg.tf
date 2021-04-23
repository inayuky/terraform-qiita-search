variable "ingress_port" {
  description = "通信を許可するingressのポート"
}
variable "vpc_id" {
  description = "SGが属するVPCのID"
}
variable "name" {
  description = "SGの名前"
}

resource "aws_security_group" "this" {
  name   = var.name
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  from_port         = var.ingress_port
  to_port           = var.ingress_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet0_id" {
  value = aws_subnet.public0.id
}

output "public_subnet1_id" {
  value = aws_subnet.public1.id
}

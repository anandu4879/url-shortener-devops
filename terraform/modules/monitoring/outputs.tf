output "instance_id" {
  value = aws_instance.monitoring.id
}

output "monitoring_sg_id" {
  value = aws_security_group.monitoring.id
}
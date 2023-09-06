output "mongo_public_ips" {
    value = aws_instance.mongo_instance[*].public_ip
}

output "app_public_ip" {
    value = aws_instance.app_instance.public_ip
}
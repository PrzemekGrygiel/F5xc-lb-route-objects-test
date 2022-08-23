output "public_ips" {
description = "List of public IP addresses assigned to instances"
value       = [aws_instance.vpc1-vms.*.public_ip]
}
output "instance_ip" {
  description = "The public DNS address of the EC2 instance"
  value       = aws_instance.shopping_list_instance.public_dns
}

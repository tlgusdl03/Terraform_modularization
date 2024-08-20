output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.ec2_instance.id
}

output "public_ip" {
  description = "The public IP of the EC2 instance."
  value       = aws_instance.ec2_instance.public_ip
}

output "key_file" {
  description = "The location of the private key file."
  value       = local_file.ssh_key.filename
}

output "ec2-sg-cli" {
  description = "CLI 서버에 적용할 보안그룹의 id"
  value = aws_security_group.ec2_sg.id
}
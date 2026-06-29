output "k3s_server_public_ip" {
  value = aws_instance.k3s_server.public_ip
}

output "k3s_worker_1_public_ip" {
  value = aws_instance.k3s_worker_1.public_ip
}

output "k3s_worker_2_public_ip" {
  value = aws_instance.k3s_worker_2.public_ip
}
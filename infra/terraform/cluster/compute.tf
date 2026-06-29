data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "k3s_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.k3s_sg.id]
  key_name                    = "phoenix-k3s-key"
  associate_public_ip_address = true

  tags = {
    Name = "phoenix-k3s-server"
  }
}
resource "aws_instance" "k3s_worker_1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.k3s_sg.id]
  key_name                    = "phoenix-k3s-key"
  associate_public_ip_address = true

  tags = {
    Name = "phoenix-k3s-worker-1"
  }
}

resource "aws_instance" "k3s_worker_2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.k3s_sg.id]
  key_name                    = "phoenix-k3s-key"
  associate_public_ip_address = true

  tags = {
    Name = "phoenix-k3s-worker-2"
  }
}
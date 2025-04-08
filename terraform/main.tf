variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region     = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "lab_server" {
  ami           = "ami-0989fb15ce71ba39e"
  instance_type = "t3.micro"
  key_name      = "cicd-key"

  vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]

  tags = {
    Name = "terraform-lab"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y apache2
              systemctl start apache2
              systemctl enable apache2
              EOF

  provisioner "file" {
    source      = "../index.html"
    destination = "/home/ubuntu/index.html"
  }


  provisioner "file" {
    source      = "../style.css"
    destination = "/home/ubuntu/style.css"
  }

 
  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/index.html /var/www/html/index.html",
      "sudo mv /home/ubuntu/style.css /var/www/html/style.css"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("cicd-key.pem")
    host        = self.public_ip
  }
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


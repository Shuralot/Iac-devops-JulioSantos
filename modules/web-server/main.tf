resource "aws_security_group" "web_sg" {
  name        = "web-sg-${var.ambiente}"
  description = "Security group para o servidor web"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH restrito"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.meu_ip}/32"]
  }

  ingress {
    description = "HTTP aberto"
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

  tags = {
    Name     = "web-sg-${var.ambiente}"
    Curso    = "Pós-graduação DevOps - CESAR School"
    Ambiente = var.ambiente
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              dnf install -y httpd
              systemctl enable httpd
              systemctl start httpd
              cat <<HTML > /var/www/html/index.html
              <html>
              <body>
              <h1>Atividade 1 Terraform</h1>
              <p>Aluno: Júlio Santos</p>
              <p>Turma: Pós-graduação DevOps - CESAR School</p>
              </body>
              </html>
              HTML
              EOF

  tags = {
    Name     = "web-server-${var.ambiente}"
    Curso    = "Pós-graduação DevOps - CESAR School"
    Ambiente = var.ambiente
  }
}
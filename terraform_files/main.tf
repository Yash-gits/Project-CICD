# SERVER1: 'MASTER-SERVER' (with Jenkins, Maven, Docker, Ansible, Trivy)

resource "aws_security_group" "my_security_group1" {
  name        = "my-security-group1"
  description = "Allow SSH, HTTP, HTTPS, 8080 for Jenkins & Maven"

  ingress { from_port = 22   to_port = 22   protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 80   to_port = 80   protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 443  to_port = 443  protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 8080 to_port = 8080 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 8081 to_port = 8081 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }

  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_instance" "my_ubuntu_instance1" {
  ami                    = "ami-02b8269d5e85954ef"
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.my_security_group1.id]
  key_name               = "invalidUSER"

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name = "MASTER-SERVER"
  }

  # USER DATA (Ubuntu replacement for yum+maven+java)
  user_data = <<-EOF
    #!/bin/bash
    sleep 60
    sudo apt update -y
    sudo apt install -y openjdk-17-jdk maven
  EOF

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      private_key = file("./invalidUSER.pem")
      user        = "ubuntu"
      host        = self.public_ip
    }

    inline = [
      "sleep 200",

      # Git
      "sudo apt update -y",
      "sudo apt install -y git",

      # Jenkins
      "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
      "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list",
      "sudo apt update -y",
      "sudo apt install -y jenkins",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",

      # Docker
      "sudo apt install -y ca-certificates curl gnupg",
      "curl -fsSL https://get.docker.com | sudo sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker jenkins",
      "sudo chmod 666 /var/run/docker.sock",

      # Trivy
      "wget https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb",
      "sudo dpkg -i trivy_0.18.3_Linux-64bit.deb",

      # Ansible
      "sudo apt install -y software-properties-common",
      "sudo add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo apt install -y ansible"
    ]
  }
}

output "ACCESS_YOUR_JENKINS_HERE" {
  value = "http://${aws_instance.my_ubuntu_instance1.public_ip}:8080"
}

output "Jenkins_Initial_Password" {
  value = "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
}

output "MASTER_SERVER_PUBLIC_IP" {
  value = aws_instance.my_ubuntu_instance1.public_ip
}

output "MASTER_SERVER_PRIVATE_IP" {
  value = aws_instance.my_ubuntu_instance1.private_ip
}

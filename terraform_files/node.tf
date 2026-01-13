# SERVER2: 'NODE-SERVER' (with Docker & Kubernetes)
# STEP1: CREATING A SECURITY GROUP FOR DOCKER-K8S
resource "aws_security_group" "my_security_group2" {
  name        = "my-security-group4"
  description = "Allow K8s ports"

  ingress { from_port = 22 to_port = 22 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 80 to_port = 80 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 443 to_port = 443 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 6443 to_port = 6443 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 8001 to_port = 8001 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 8080 to_port = 8080 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 10250 to_port = 10250 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 30000 to_port = 32767 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }

  egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }
}

# STEP2: CREATE UBUNTU EC2
resource "aws_instance" "my_ubuntu_instance2" {
  ami                    = "ami-02b8269d5e85954ef"
  instance_type          = "t2.medium"
  vpc_security_group_ids = [aws_security_group.my_security_group2.id]
  key_name               = "invalidUSER"

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name = "NODE-SERVER"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      private_key = file("./invalidUSER.pem")
      user        = "ubuntu"
      host        = self.public_ip
    }

    inline = [
      "sleep 200",

      # Docker
      "sudo apt update -y",
      "sudo apt install -y ca-certificates curl gnupg",
      "curl -fsSL https://get.docker.com | sudo sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo chmod 777 /var/run/docker.sock",

      # Disable swap (required for Kubernetes)
      "sudo swapoff -a",
      "sudo sed -i '/ swap / s/^/#/' /etc/fstab",

      # Install Kubernetes
      "sudo apt install -y apt-transport-https ca-certificates curl",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg",
      "echo deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ / | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt update -y",
      "sudo apt install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl",
      "sudo systemctl enable --now kubelet",

      # Initialize cluster
      "sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU --ignore-preflight-errors=Mem",

      # Configure kubectl
      "mkdir -p $HOME/.kube",
      "sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",

      # Calico Network
      "kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml",
      "kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml",

      # Allow scheduling on control plane
      "kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true"
    ]
  }
}

output "NODE_SERVER_PUBLIC_IP" {
  value = aws_instance.my_ubuntu_instance2.public_ip
}

output "NODE_SERVER_PRIVATE_IP" {
  value = aws_instance.my_ubuntu_instance2.private_ip
}

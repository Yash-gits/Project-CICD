# Devops-Project.

![Tools](https://github.com/pandacloud1/DevopsProject1/assets/134182273/b553e105-136d-4ce4-93ec-540809cdc6ee)

This repository contains the following components:

1.  Simple Java Code
2.  Dockerfile
3.  Kubernetes manifests (`deployment.yaml` & `service.yaml`)
4.  Jenkinsfile (CI & CD)
5.  Terraform code

## Algorithm

#### 1.  Create two EC2 instances: 'Master-Server' & 'Node-Server' using Terraform

    a. 'Master-Server' will have Java, Jenkins, Maven, Docker, Ansible, & Trivy packages
    b. 'Node-Server' will have Docker, Kubeadm & Kubernetes packages

#### 2.  Establish passwordless connection between 'Master-Server' & 'Node-Server'
     ### Commands to run in 'Node-Server'
     sudo su -
     passwd ubuntu                         # (set password)
     vi /etc/ssh/sshd_config                 # (Allow 'PermitRootLogin yes' & allow 'PasswordAuthentication yes')
     sudo systemctl restart ssh


     <Commands to run in 'Master-Server'>
     ssh-keygen             # (this will generate ssh key, press enter when prompted)
     ssh-copy-id ubuntu@<NODE_PRIVATE_IP>


     ssh-copy-id ubuntu@<Node_Private_IP>  # (enter 'yes' when prompted & enter the Node's ubuntu password when prompted)


#### . Install Docker, kubectl & Minikube on Ubuntu 


    # Install Docker
    sudo apt install -y ca-certificates curl gnupg && \
    sudo install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null && \
    sudo chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    sudo apt update && \
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    sudo systemctl start docker && \
    sudo systemctl enable docker && \
    sudo usermod -aG docker ubuntu && \
    newgrp docker && \
    docker run hello-world && \

    # Install kubectl
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-    release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    sudo install kubectl /usr/local/bin/kubectl && \
    rm kubectl && \

    # Install Minikube
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    sudo install minikube-linux-amd64 /usr/local/bin/minikube && \
    rm minikube-linux-amd64 && \
    minikube start --driver=docker && \
    kubectl get nodes && \
    kubectl get pods -A
    



#### 3.  Access Jenkins portal & add credentials in Jenkins portal as below:
     (Manage Jenkins --> Credentials --> System --> Global credentials)

    a. Dockerhub credentials - username & password (Use 'secret text' & save them separately)
    b. K8s server username with private key (Use 'SSH Username with private key')
    c. Add Github username & token (Generate Github token & save as 'secret key' in Jenkins server)
        (Github: Github settings --> Developer settings --> Personal Token classic --> Generate)
    d. Dockerhub token (optional) (Generate token & save as 'secret key')
        (Dockerhub: Account --> Settings --> Security --> Generate token & copy it)

#### 4.  Add required plugins in Jenkins portal
     (Manage Jenkins --> Plugins --> Available plugins --> 'ssh agent' --> Install)
     (This plugin is required to generate ssh agent syntax using pipeline syntax generator)

#### 5.  Access Jenkins portal & paste the 'CI-pipeline' code
     Run the pipeline

#### 6.  Now create another 'CD-pipeline'
     a. Enter the 'Pipeline name', 'Project Name' & 'Node-Server' Private IP under the environment variables section
     b. Run the pipeline
     c. Access the content from the browser using <Node_Server_Public_IP>:<NodePort_No>

#### 7.  Automation
     a. Automate the CD pipeline after CI pipeline is built successfully
        (CD-pipeline --> Configure --> Build Triggers --> Projects to watch (CI-pipeline) --> 
        Trigger only if build is stable --> Save)
     b. Automate CI pipeline if any changes are pushed to Github
        (Webhook will be created in Github & trigger will be created in Jenkins)
        Jenkins --> Configure --> Build triggers --> 'Github hook trigger for GitSCM polling' --> Save
        Jenkins --> <Your_Account> --> Configure --> API Tokens --> <Jenkins-API-Token>
        Github --> <Your-Repo> --> Settings --> Webhooks --> "<Jenkins-url>:8080/github-webhook/"; -->
        Content type: json;     Secret: <Jenkins-API-Token> --> Add Webhook
        (Try making any changes in your code & the pipeline should automatically trigger)

#### 8.  Deletion
     a. Run the below command in Terraform to destroy the entire infrastructure
        terraform destroy --auto-approve

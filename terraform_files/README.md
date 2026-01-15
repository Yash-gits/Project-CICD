### TERRAFORM FILES
--
#### The above Terraform files will create 'Jenkins' & 'K8s' servers
#### Master-Server --> Git, Maven, Docker, Trivy, Ansible
#### Node-Server --> Docker, K8s (Kubeadm)

##### *NOTE*:
1. Create a 'My_key.pem' from AWS EC2 console 
2. Save the key file in the same location as your terraform code
3. Download and Install Packages in Master-Server: DOCKER, MINIKUBE, KUBECTL
4. INSTALL PLUGINS IN JENKINS: ECLIPSE TERUMINE (JDK), STAGE VIEW, DOCKER(ALL) 

on master: 
```
vim docker.sh
sudo chmod a+x docker.sh
```
on node: 

```
vim docker.sh
sudo chmod a+x docker.sh


vim k8s.sh
sudo chmod a+x k8s

vim minikube.sh
sudo chmod a+x minikube.sh

./docker.sh
./minikube.sh
.k8s.sh

```

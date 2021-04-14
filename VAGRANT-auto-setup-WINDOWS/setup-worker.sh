#!/usr/bin/bash

#using tutorial https://phoenixnap.com/kb/install-kubernetes-on-ubuntu
#make sure the network deployment is done the way this script is written, and not the website way

printf "Enter the password for `whoami` :- "
read password
printf "Enter what hostname do you want for the WORKER node :- "
read node_name
printf "Enter MASTER node's IP address :- "
read master_IP
printf "Enter username for the MASTER_NODE :- "
read master_user
printf "Enter password for user in MASTER_NODE :- "
read master_password



if [ `echo $password` == '' ]
then
echo "Enter valid password for the user installing kubernetes"
exit 1
fi


if [ `echo $node_name` == '' ]
then
echo "Enter valid hostname for the control plane"
exit 1
fi
#!/usr/bin/bash


apt-get update
apt-get install -y docker.io
systemctl enable docker
systemctl start docker
apt-get install -y curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
# apt-get install -y kubeadm kubelet kubectl
apt-get install -y kubeadm=1.21.0-00 kubelet=1.21.0-00 kubectl=1.21.0-00
apt-mark hold kubeadm kubelet kubectl
swapoff -a



printf "\n\n"

/vagrant_data/JOIN_NETWORK.sh

mkdir -p /home/vagrant/.kube
cp /vagrant_data/config /home/vagrant/.kube/config

# cp /vagrant_data/JOIN_NETWORK.sh /home/vagrant/JOIN_NETWORK.sh
# chmod +x /home/vagrant/JOIN_NETWORK.sh
# /home/vagrant/JOIN_NETWORK.sh




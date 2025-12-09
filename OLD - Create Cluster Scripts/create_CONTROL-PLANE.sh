#!/usr/bin/bash


###################################################################################################
# Create a kubernetes master node using this script                                               #
################################################################################################### 


#using tutorial https://phoenixnap.com/kb/install-kubernetes-on-ubuntu
#make sure the network deployment is done the way this script is written, and not the website way

# this worked with 
# ubuntu 20.10
# docker 20.10.7
# kubernetes 1.22

###################################################################################################
# after reboot...swap area will be enabled ...restart kubectl service issue these below commands  #
# sudo swapoff -a                                                                                 #  
# sudo systemctl start kubelet       
#
# add this to ~/.bashrc
# echo Kolkata#1 | sudo -S swapoff -a
# echo Kolkata#1 | sudo -S sudo systemctl start kubelet
#
# printf "\n\n"
#                                                             
###################################################################################################  




printf "Enter the password for the user `whoami` :- "
read password


if [ `echo $password` == '' ]
then
echo "Enter valid password for the user installing kubernetes"
exit 1
fi


# this is required to start kubelets after host machine reboots
echo "`printf "\n\n"` 
echo $password | sudo -S swapoff -a
echo $password | sudo -S sudo systemctl start kubelet
printf '\n\n'" >> ~/.bashrc



echo $password | sudo -S apt-get update
echo $password | sudo -S apt-get install -y docker.io
echo $password | sudo -S systemctl enable docker
echo $password | sudo -S systemctl start docker
# Add current user to docker group so that docker command can be run by non root user
echo $password | sudo -S usermod -aG docker $USER
# install curl
echo $password | sudo -S apt-get install -y curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo $password | sudo -S apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
echo $password | sudo -S apt-get install -y kubeadm kubelet kubectl
echo $password | sudo -S apt-mark hold kubeadm kubelet kubectl
echo $password | sudo -S swapoff -a
# echo $password | sudo -S hostnamectl set-hostname $master_node_hostname

# https://giters.com/kubernetes/kubeadm/issues/2559?amp=1
# update /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# In Ubuntu distro, docker comes by default with the native control group driver cgroupfs while kublet assumes systemd. So I changed the kublet config in /etc/systemd/system/kubelet.service.d/10-kubeadm to Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --cgroup-driver=cgroupfs"
echo $password | sudo -S cp /etc/systemd/system/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf_BACKUP
echo $password | sudo -S sed -i 's/kubelet.conf"/kubelet.conf --cgroup-driver=cgroupfs"/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

echo $password | sudo -S kubeadm init --pod-network-cidr=10.244.0.0/16 2>&1 | tee join.txt
mkdir -p $HOME/.kube
echo $password | sudo -S cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
echo $password | sudo -S chown $(id -u):$(id -g) $HOME/.kube/config

#using flannel for virtual network
#see https://kubernetes.io/docs/concepts/cluster-administration/addons/ for other options

# in future this below command will not work as 
# Warning: policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
# check https://github.com/flannel-io/flannel for details
curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml -O
kubectl apply -f kube-flannel.yml



# https://github.com/calebhailey/homelab/issues/3
# By default, your cluster will not schedule pods on the control-plane node for security reasons. If you want to be able to schedule pods on the control-plane node, e.g. for a single-machine Kubernetes cluster for development, run:
# kubectl taint nodes --all node-role.kubernetes.io/master-

kubectl taint nodes --all node-role.kubernetes.io/master-

printf "\n\n"

tail -20 join.txt


tail -2 join.txt > /home/$USER/JOIN_NETWORK.sh
rm join.txt
rm kube-flannel.yml




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

# kubeadm init --pod-network-cidr=10.244.0.0/16 2>&1 | tee join.txt
kubeadm init --pod-network-cidr=192.168.0.0/16 2>&1 | tee join.txt
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown $(id -u):$(id -g) /home/vagrant/.kube/config

#using flannel for virtual network
#see https://kubernetes.io/docs/concepts/cluster-administration/addons/ for other options

# curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml -O
# kubectl apply -f kube-flannel.yml


echo "[TASK 3] Deploy Calico network"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml >/dev/null 2>&1


printf "\n\n"

tail -20 join.txt


tail -2 join.txt > /vagrant_data/JOIN_NETWORK.sh
cp /home/vagrant/.kube/config /vagrant_data/config

rm join.txt
rm kube-flannel.yml
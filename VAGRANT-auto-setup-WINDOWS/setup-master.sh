#!/usr/bin/bash



# kubeadm init --pod-network-cidr=10.244.0.0/16 2>&1 | tee join.txt  # ------- for flannel
# kubeadm init --pod-network-cidr=192.168.0.0/16 2>&1 | tee join.txt # --------- for calico

echo "[TASK] Pull required containers"
kubeadm config images pull >/dev/null 2>&1

echo "[TASK] Initialize Kubernetes Cluster"
#kubeadm init --apiserver-advertise-address=172.16.16.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null
kubeadm init --apiserver-advertise-address=192.168.1.100 --pod-network-cidr=192.168.0.0/16 >> /root/kubeinit.log 2>/dev/null

echo "[TASK] Deploy Calico network"
kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml >/dev/null 2>&1


echo "[TASK] Setup kubeconfig"
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

cp -i /etc/kubernetes/admin.conf /vagrant_data/config

#using flannel for virtual network
#see https://kubernetes.io/docs/concepts/cluster-administration/addons/ for other options

# curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml -O
# kubectl apply -f kube-flannel.yml


# Deploy Calico network"
# kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml 

echo "[TASK] Generate and save cluster join command"
kubeadm token create --print-join-command > /vagrant_data/JOIN_NETWORK.sh



echo "[TASK] Downloading and Installing the mount Components"
apt update -qq >/dev/null 2>&1
sudo apt install -qq -y nfs-kernel-server 


echo "[TASK] Exporting a General Purpose Mount"
mkdir /var/nfs/PV -p
chown nobody:nogroup /var/nfs/PV

echo "[TASK] Configuring the NFS Exports on the Host Server"
cat >>/etc/exports<<EOF
/var/nfs/PV worker-1(rw,sync,no_subtree_check)
EOF
systemctl restart nfs-kernel-server


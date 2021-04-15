#!/bin/bash


echo "[TASK] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

echo "[TASK] Stop and Disable firewall"
systemctl disable --now ufw >/dev/null 2>&1

echo "[TASK] Enable and Load Kernel modules"
cat >>/etc/modules-load.d/containerd.conf<<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "[TASK] Add Kernel settings"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system >/dev/null 2>&1

echo "[TASK] Install containerd runtime"
# apt update -qq >/dev/null 2>&1
# apt install -qq -y containerd apt-transport-https >/dev/null 2>&1
# apt install -qq -y apt-transport-https >/dev/null 2>&1
# mkdir /etc/containerd
# containerd config default > /etc/containerd/config.toml
# systemctl restart containerd
# systemctl enable containerd >/dev/null 2>&1


apt-get install -qq -y curl >/dev/null 2>&1

apt install -qq -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common >/dev/null 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update -qq >/dev/null 2>&1
apt install -qq -y docker-ce=5:19.03.10~3-0~ubuntu-focal containerd.io >/dev/null 2>&1


systemctl enable docker
systemctl start docker



echo "[TASK] Add apt repo for kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - >/dev/null 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" >/dev/null 2>&1

echo "[TASK] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt-get install -y kubeadm=1.21.0-00 kubelet=1.21.0-00 kubectl=1.21.0-00 >/dev/null 2>&1
apt-mark hold kubeadm kubelet kubectl

# echo "[TASK 8] Enable ssh password authentication"
# sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
# echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
# systemctl reload sshd

# echo "[TASK 9] Set root password"
# echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
# echo "export TERM=xterm" >> /etc/bash.bashrc

echo "[TASK] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.16.16.100   master
172.16.16.101   worker-1
EOF
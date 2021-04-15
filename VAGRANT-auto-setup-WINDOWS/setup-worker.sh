#!/usr/bin/bash



echo "[TASK] Join cluster"
bash /vagrant_data/JOIN_NETWORK.sh

echo "[TASK] Setup kubeconfig"
mkdir -p /home/vagrant/.kube
chown vagrant:vagrant /home/vagrant/.kube
cp /vagrant_data/config /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config



echo "[TASK ] Downloading and Installing the mount Components"
apt update -qq >/dev/null 2>&1
sudo apt install -qq -y nfs-common >/dev/null 2>&1

echo "[TASK ] Creating Mount Points and Mounting Directories on the Client"
mkdir -p /nfs/PV
mount master:/var/nfs/PV /nfs/PV
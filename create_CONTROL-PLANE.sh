#using tutorial https://phoenixnap.com/kb/install-kubernetes-on-ubuntu
#make sure the network deployment is done the way this script is written, and not the website way

printf "Enter the password for the user"
read password
printf "Enter what hostname you want for the Control Plane"
read master_node_hostname

#export password=osboxes.org

#if [ `echo $password` == 'CHANGE_ME' ]
#then
#echo "update the password field with user's password"
#exit 1
#fi


if [ `echo $password` == '' ]
then
echo "Enter valid password for the user installing kubernetes"
exit 1
fi


if [ `echo $master_node_hostname` == '' ]
then
echo "Enter valid hostname for the control plane"
exit 1
fi



echo $password | sudo -S apt-get update
echo $password | sudo -S apt-get install -y docker.io
echo $password | sudo -S systemctl enable docker
echo $password | sudo -S systemctl start docker
echo $password | sudo -S apt-get install -y curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo $password | sudo -S apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
echo $password | sudo -S apt-get install -y kubeadm kubelet kubectl
echo $password | sudo -S apt-mark hold kubeadm kubelet kubectl
echo $password | sudo -S swapoff -a
echo $password | sudo -S hostnamectl set-hostname $master_node_hostname
echo $password | sudo -S kubeadm init --pod-network-cidr=10.244.0.0/16 2>&1 | tee join.txt
mkdir -p $HOME/.kube
echo $password | sudo -S cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
echo $password | sudo -S chown $(id -u):$(id -g) $HOME/.kube/config

#using flannel for virtual network
#see https://kubernetes.io/docs/concepts/cluster-administration/addons/ for other options

curl https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml -O
kubectl apply -f kube-flannel.yml


printf "\n\n"

tail -20 join.txt


tail -2 join.txt > /home/$USER/JOIN_NETWORK.sh
rm join.txt
rm kube-flannel.yml
#using tutorial https://phoenixnap.com/kb/install-kubernetes-on-ubuntu
#make sure the network deployment is done the way this script is written, and not the website way

printf "Enter the password for the user"
read password
printf "Enter what hostname you want for the Control Plane"
read node_name

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


if [ `echo $node_name` == '' ]
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
echo $password | sudo -S hostnamectl set-hostname $node_name


printf "\n\n"

printf "Go to master node and get the kubeadm join command saved in /home/<USER_RUNNING_KUBERNETES>/JOIN_NETWORK.sh. Run the command in the file to join network"



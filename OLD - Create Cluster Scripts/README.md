# Kubernetes-Template

This repo gives two options to create kubernetes clusters (one of those broke on Sep 13 2023 - https://kubernetes.io/blog/2023/08/31/legacy-package-repository-deprecation/)

## Option 1 (Working)

1. Create a vagrant ubuntu image and designate that as the control plane
2. Create another vagrant ubuntu image and designate that as worker.
3. Run the scripts described below
4. After creating the worker node, go back to master and join the worker to master. The create_WORKER-NODE.sh file has the instruction at the end of the file.

Create kubernetes cluster on ubuntu 20.04

1.  Create Control Plane with `create_CONTROL-PLANE.sh
~$: bash <(wget -qO- https://raw.githubusercontent.com/kausgang/Kubernetes-Template/main/create_CONTROL-PLANE.sh)`

2.  Create worker node with `create_WORKER-NODE.sh
~$: bash <(wget -qO- https://raw.githubusercontent.com/kausgang/Kubernetes-Template/main/create_WORKER-NODE.sh)`

## Option 2 (Broke)

Go inside VAGRANT-auto-setup-UBUNTU folder and issue `vagrant up` command. For the Control plane the ansible part is included in the vagrant file. Since it didn't work after Kube changed the repo location, further work has not been done on it. But this vagrand file can show how to -

1. Set a name for the virtual machine
2. Install ansible in guest after the vm is created
3. use ansible_local to use the ansible of the guest to install/configure the guest.

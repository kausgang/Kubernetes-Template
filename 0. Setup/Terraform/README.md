# Create a kind cluster with Terraform (on NJ Laptop)

NJ machines have zscaler ZIA running and KIND requires the Zscaler root certificate applied on the cluster.

Follow this document for detail - https://github.com/kausgang/TechLearning/blob/main/ZScaler/Resources/Kubernetes%20fix.md

To do it with Terraform on NJ machine follow this 

1. (Optional for NJ machine) Get the zscaler root certificate like this - https://github.com/kausgang/TechLearning/blob/main/ZScaler/Resources/Kubernetes%20fix.md#step-1-export-the-zscaler-root-certificate

2. (Optional for NJ machine) Replace the Zscaler_Root_CA.crt file found in the [Create-cluster](./Create-Cluster/) folder

3. Install terraform, kind, podman or docker

4. cd into `[Create-Cluster](./Create-Cluster/)` folder

5. `terraform init`

6. `terraform apply -auto-approve`

7. When you want to delete cluster - `terraform destroy`
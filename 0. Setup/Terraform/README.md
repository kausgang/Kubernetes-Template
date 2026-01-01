# Create a kind cluster with Terraform (on NJ Laptop)

NJ machines have zscaler ZIA running and KIND requires the Zscaler root certificate applied on the cluster.

Follow this document for detail - https://github.com/kausgang/TechLearning/blob/main/ZScaler/Resources/Kubernetes%20fix.md

To do it with Terraform on NJ machine follow this 

1. (Optional for NJ machine) Get the zscaler root certificate like this - https://github.com/kausgang/TechLearning/blob/main/ZScaler/Resources/Kubernetes%20fix.md#step-1-export-the-zscaler-root-certificate

2. (Optional for NJ machine) Replace the Zscaler_Root_CA.crt file found in the [Create-cluster](./Create-Cluster/) folder

3. Install terraform, kind, podman or docker

4. cd into `[Create-Cluster](./Create-Cluster/)` folder

5. `terraform init` to download the specified version of the Kubernetes provider

6. (Optional) Next, use `terraform plan` to display a list of resources to be created, and highlight any possible unknown attributes at apply time. For Deployments, all disk options are shown at plan time, but none will be created unless explicitly configured in the Deployment resource

7. `terraform apply -auto-approve` **This is done for NJ machine. If you are not on NJ machine, change [create-cluster](./Create-Cluster/create-cluster.tf) file accordingly**

8. When you want to delete cluster - `terraform destroy`

## Explaination of Terraform files

- The terraform files create a kind cluster by executing commands. The `create-cluster.tf` is the main file and it uses `variables.tf` & `versions.tf`.
- `versions.tf` contains the providers. When you run terraform init, it downloads the providers. Since here I am only running local executable, i only need null provider - https://registry.terraform.io/providers/hashicorp/null/latest
- The kind cluster is created with a config file called - `kind-config.yaml`
- this config file creates two mount points 
    - one for zscaler certificate - https://github.com/kausgang/TechLearning/blob/main/ZScaler/Resources/Kubernetes%20fix.md
    - Other for creating a persistent volume - https://github.com/kausgang/Kubernetes-Template/tree/main/Volume
    if you need to create a PV or PVC later, you can use this mount point.

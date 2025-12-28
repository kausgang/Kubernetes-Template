
# 1) Create kind cluster 
resource "null_resource" "kind_cluster" {

    triggers = { cluster_name = var.cluster_name }


    # Ensure kind is available in PATH
    provisioner "local-exec" {
    command = <<-EOT
        kind create cluster --name ${var.cluster_name} --config kind-config.yaml
    EOT
    interpreter = ["cmd", "/C"]
    }

    provisioner "local-exec" { 
    command = "podman exec -it ${var.cluster_name}-control-plane update-ca-certificates"
    }

    provisioner "local-exec" { 
    command = "podman exec -it ${var.cluster_name}-control-plane systemctl restart containerd"
    }

    # Delete the cluster on terraform destroy

    provisioner "local-exec" {
    when        = destroy
    interpreter = ["cmd", "/C"]
    command     = "kind delete cluster --name ${self.triggers.cluster_name}"
    on_failure  = continue
    }


}



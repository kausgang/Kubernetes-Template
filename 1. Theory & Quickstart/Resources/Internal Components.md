Absolutely, Kaustav! Here's a comprehensive reference document that covers what gets created by default when you set up a Kubernetes cluster (including with tools like `kind`), and what internal components or configurations are typically present but not always visible. This should serve as your go-to guide for Kubernetes cluster internals and setup trivia.

---

# 🧠 Kubernetes Cluster Setup: Internal Components & Defaults

## 📌 Overview

When you set up a Kubernetes cluster—whether using `kubeadm`, `kind`, `minikube`, or a cloud provider—several components and configurations are created automatically. Some are visible (like ConfigMaps), while others are internal or abstracted away.

---

## 🔐 Certificates & CA

### ✅ Is a Certificate Authority (CA) Created by Default?

Yes. Kubernetes **automatically generates a CA** when you initialize a cluster using tools like `kubeadm` or `kind`. This CA is used to sign:

- API server certificate
- kubelet client certificates
- etcd certificates
- front-proxy certificates (for aggregated APIs)

### 📁 Location (for `kubeadm`-based clusters)

Certificates are typically stored in:

```
/etc/kubernetes/pki/
```

Includes:
- `ca.crt`, `ca.key`
- `apiserver.crt`, `apiserver.key`
- `etcd/ca.crt`, `etcd/ca.key`
- `front-proxy-ca.crt`, `front-proxy-ca.key`

In `kind`, these are embedded in the container image and managed internally.

---

## 📦 ConfigMaps Created by Default

### In `kube-system` Namespace:

- `kube-root-ca.crt`: Contains the root CA certificate used by Kubernetes.
- `extension-apiserver-authentication`: Used for aggregated APIs.
- `coredns`: Configuration for CoreDNS.
- `kube-proxy`: Configuration for kube-proxy.
- `kubeadm-config`: Cluster-wide configuration (only in kubeadm setups).

---

## 🧠 Internal Components & Hidden Defaults

### 1. **Service Account Tokens**
- Every namespace gets a default service account.
- Tokens are auto-generated and mounted into pods unless disabled.

### 2. **Default RBAC Roles**
- `cluster-admin`, `admin`, `edit`, `view` roles are created.
- `system:*` prefixed roles for internal components.

### 3. **Node Bootstrap Tokens**
- Used for kubelet authentication during node join.
- Stored as secrets in `kube-system`.

### 4. **Default Services**
- `kubernetes` service in `default` namespace pointing to the API server.

### 5. **Admission Controllers**
- Enabled by default: `NamespaceLifecycle`, `LimitRanger`, `ServiceAccount`, `DefaultStorageClass`, etc.
- Controlled via API server flags.

---

## 🧰 Kind-Specific Notes

- Kind uses Docker containers as nodes.
- Certificates and kubeconfig are generated internally.
- You can inspect them using:
  ```bash
  docker exec -it kind-control-plane cat /etc/kubernetes/pki/ca.crt
  ```

---

## 🔍 Useful Commands for Inspection

```bash
# List all ConfigMaps in kube-system
kubectl get configmap -n kube-system

# View CA certificate
kubectl get configmap kube-root-ca.crt -n kube-system -o yaml

# List all secrets (includes service account tokens)
kubectl get secrets -A

# View default service account
kubectl get sa default -n default -o yaml

# View cluster roles
kubectl get clusterroles
```

---

## 📚 Trivia & Tips

- Kubernetes uses **x509 certificates** for mutual TLS between components.
- The **API server** is the only component that talks to etcd directly.
- **Kubelet** uses the node's hostname as its identity unless overridden.
- **Aggregated APIs** (like metrics-server) rely on front-proxy CA and client certs.
- **Kubeconfig** files contain client certs and CA certs for authentication.

---

Would you like me to save this as a markdown or PDF file for easy reference? I can also expand this into a more detailed guide with diagrams if you'd like!
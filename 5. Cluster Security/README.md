Absolutely! Let's dive deep into **Kubernetes security fundamentals**, starting from the basics and building up to a practical project. This guide is designed for beginners, so I’ll explain each concept thoroughly with examples.

---

## 📘 Tutorial: Securing Your Kubernetes APIs

### **Overview**
Security in Kubernetes is critical to ensure that workloads are isolated, access is controlled, and the cluster is protected from malicious or accidental misuse. In this tutorial, you’ll learn:

- **Kubernetes RBAC**: Roles, ClusterRoles, RoleBindings
- **ServiceAccounts**
- **Pod Security Standards (PSS)**
- **Network Policies**

---

## 🔐 1. Kubernetes RBAC (Role-Based Access Control)

### **What is RBAC?**
RBAC (Role-Based Access Control) is a method of regulating access to Kubernetes resources based on the roles of individual users or service accounts.

### **Key Concepts**

| Component       | Description |
|----------------|-------------|
| **Role**        | Defines permissions within a **namespace**. |
| **ClusterRole** | Defines permissions **cluster-wide** or across multiple namespaces. |
| **RoleBinding** | Grants a Role to a user or ServiceAccount **within a namespace**. |
| **ClusterRoleBinding** | Grants a ClusterRole to a user or ServiceAccount **across the cluster**. |

### **Example: Create a Role and RoleBinding**

**Role (read-only access to pods):**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev-team
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

**RoleBinding (assign role to a ServiceAccount):**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-binding
  namespace: dev-team
subjects:
- kind: ServiceAccount
  name: dev-sa
  namespace: dev-team
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

## 👤 2. ServiceAccounts

### **What is a ServiceAccount?**
A **ServiceAccount** is an identity used by pods to interact with the Kubernetes API. By default, every pod gets a default ServiceAccount in its namespace, but you can create custom ones for better control.

### **Why Use Custom ServiceAccounts?**
- To follow **least privilege** principles.
- To assign specific RBAC permissions.
- To isolate workloads by access level.

### **Example: Create a ServiceAccount**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev-sa
  namespace: dev-team
```

Then, in your pod spec:
```yaml
spec:
  serviceAccountName: dev-sa
```

---

## 🛡️ 3. Pod Security Standards (PSS)

### **What is Pod Security?**
Pod Security Standards define **security policies** for how pods should be configured. They help prevent privilege escalation, enforce container isolation, and restrict risky behaviors.

### **Pod Security Admission (PSA)**
As of Kubernetes v1.25+, **PodSecurityPolicies (PSP)** are deprecated and replaced by **Pod Security Admission (PSA)**.

### **Pod Security Levels:**

| Level | Description |
|-------|-------------|
| **Privileged** | No restrictions. Full access. |
| **Baseline** | Minimally restrictive. Allows common use cases. |
| **Restricted** | Highly secure. Enforces best practices. |

### **Example: Enforce Restricted Policy in a Namespace**
```yaml
apiVersion: policy/v1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'MustRunAs'
    ranges:
    - min: 1
      max: 65535
```

> ⚠️ Note: If you're using Kubernetes v1.25+, use **Pod Security Admission** instead of PSP.

---

## 🌐 4. Network Policies

### **What is a Network Policy?**
Network Policies control **how pods communicate** with each other and with external endpoints. By default, all pods can talk to each other. Network Policies allow you to **restrict traffic**.

### **Key Concepts**

- **Ingress**: Incoming traffic to a pod.
- **Egress**: Outgoing traffic from a pod.
- **Selectors**: Define which pods the policy applies to.

### **Example: Allow traffic only from specific pods**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app-traffic
  namespace: dev-team
spec:
  podSelector:
    matchLabels:
      app: api-v1
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
```

This policy allows only pods with label `app=frontend` to talk to `api-v1`.

---

## 🛠️ Practice Project: Secure Multi-Team Kubernetes Setup

### **Goal**
Create isolated namespaces for different teams (`dev-team`, `qa-team`) with:

- Custom ServiceAccounts
- RBAC roles and bindings
- Pod security standards
- Network policies

---

### **1. Create Namespaces**
```bash
kubectl create namespace dev-team
kubectl create namespace qa-team
```

---

### **2. Create ServiceAccounts**
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev-sa
  namespace: dev-team
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: qa-sa
  namespace: qa-team
```

---

### **3. Create RBAC Roles and Bindings**

**Dev Team Role:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: dev-role
  namespace: dev-team
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list", "create", "delete"]
```

**Dev RoleBinding:**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-role-binding
  namespace: dev-team
subjects:
- kind: ServiceAccount
  name: dev-sa
  namespace: dev-team
roleRef:
  kind: Role
  name: dev-role
  apiGroup: rbac.authorization.k8s.io
```

Repeat similarly for `qa-team`.

---

### **4. Apply Pod Security Standards**

Use labels to enforce PSA:

```bash
kubectl label namespace dev-team pod-security.kubernetes.io/enforce=restricted
kubectl label namespace qa-team pod-security.kubernetes.io/enforce=baseline
```

---

### **5. Apply Network Policies**

Restrict communication between namespaces:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-cross-namespace
  namespace: dev-team
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: dev-team
```

This ensures only pods from the same namespace can communicate.

---

## 📎 Reference Summary

| Concept | Description | Resource |
|--------|-------------|----------|
| Role | Namespace-scoped permissions | `Role` |
| ClusterRole | Cluster-wide permissions | `ClusterRole` |
| RoleBinding | Assign Role to user/SA in namespace | `RoleBinding` |
| ServiceAccount | Identity for pods | `ServiceAccount` |
| Pod Security Standards | Enforce pod-level security | PSA labels |
| Network Policy | Control pod communication | `NetworkPolicy` |

---

Would you like me to generate the full YAML manifests for this practice project, or help you simulate it in a local Kind cluster?
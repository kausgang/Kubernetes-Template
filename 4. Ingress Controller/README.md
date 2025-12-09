Absolutely! Here's a comprehensive tutorial and reference document focused on **Ingress Controllers** in Kubernetes, with a practical project to deploy multiple API versions using path-based routing.

---

## 📘 Tutorial: Exposing APIs with Ingress Controllers

### **Overview**
Ingress resources and controllers allow external access to services running inside a Kubernetes cluster. This tutorial covers:

- Ingress resources and controllers (with a focus on Gateway API and NGINX)
- Path-based and host-based routing
- TLS/SSL termination
- Annotations for advanced configuration

---

### **1. Ingress Resources and Controllers**

#### 🔹 What is an Ingress?
An **Ingress** is a Kubernetes object that manages external access to services, typically HTTP/S traffic. It defines rules for routing requests to services based on hostnames and paths.

#### 🔹 Ingress Controllers
An Ingress resource needs a controller to implement the routing rules.

- **Gateway API**: The future of Kubernetes ingress, offering more flexibility and extensibility.
- **NGINX Ingress Controller**: Previously the most popular controller, but **no longer actively maintained** by the Kubernetes project. Still widely used and supported by the community.

#### 🔹 Install NGINX Ingress Controller (for demo purposes)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

Wait for the controller to be ready:
```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

---

### **2. Path-Based and Host-Based Routing**

#### 🔹 Path-Based Routing
Route traffic based on URL paths.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - http:
      paths:
      - path: /v1(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: api-v1
            port:
              number: 80
      - path: /v2(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: api-v2
            port:
              number: 80
```

#### 🔹 Host-Based Routing
Route traffic based on domain names.

```yaml
spec:
  rules:
  - host: v1.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-v1
            port:
              number: 80
```

---

### **3. TLS/SSL Termination**

Use **cert-manager** to automate SSL certificate provisioning.

#### 🔹 Install cert-manager
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

#### 🔹 Create ClusterIssuer (Let's Encrypt)
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

#### 🔹 Add TLS to Ingress
```yaml
spec:
  tls:
  - hosts:
    - api.example.com
    secretName: api-tls
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-v1
            port:
              number: 80
```

---

### **4. Annotations for Advanced Config**

Common annotations for NGINX Ingress:

| Annotation | Purpose |
|------------|---------|
| `nginx.ingress.kubernetes.io/rewrite-target` | Rewrite request path |
| `nginx.ingress.kubernetes.io/ssl-redirect` | Force HTTPS |
| `nginx.ingress.kubernetes.io/proxy-body-size` | Limit request body size |
| `nginx.ingress.kubernetes.io/whitelist-source-range` | Restrict access by IP |

---

## 🛠️ Practice Project: Deploy Multiple API Versions with Path-Based Routing

### **Goal**
Deploy two versions of a Spring Boot API (`v1`, `v2`) and expose them via path-based routing using NGINX Ingress.

---

### **1. Prepare API Versions**

- Create two Spring Boot apps: `api-v1` and `api-v2`
- Each app should respond with its version on `/hello`

Example response:
- `api-v1`: `"Hello from API v1"`
- `api-v2`: `"Hello from API v2"`

Build and tag Docker images:
```bash
docker build -t api-v1:latest ./api-v1
docker build -t api-v2:latest ./api-v2
```

Load into Kind:
```bash
kind load docker-image api-v1:latest
kind load docker-image api-v2:latest
```

---

### **2. Create Kubernetes Services and Deployments**

Create `api-v1-deployment.yaml` and `api-v2-deployment.yaml` with respective services.

---

### **3. Create Ingress Resource**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - host: api.local
    http:
      paths:
      - path: /v1(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: api-v1
            port:
              number: 80
      - path: /v2(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: api-v2
            port:
              number: 80
```

---

### **4. SSL with cert-manager**

- Install cert-manager
- Create `ClusterIssuer`
- Update Ingress with TLS block
- Use a real domain or configure local DNS (e.g., via `/etc/hosts`) for testing

---

## 📎 Reference Summary

| Feature | Description | Resource |
|--------|-------------|----------|
| Ingress | Route external traffic | `Ingress` |
| Controller | Implements Ingress rules | NGINX, Gateway API |
| Path Routing | Route by URL path | `path` in `Ingress` |
| Host Routing | Route by domain | `host` in `Ingress` |
| TLS Termination | HTTPS support | `cert-manager`, `ClusterIssuer` |
| Annotations | Advanced config | `metadata.annotations` |

---

Would you like me to generate the full YAML files for the v1/v2 deployments, services, and ingress setup? I can also help you configure cert-manager with a self-signed certificate for local testing.
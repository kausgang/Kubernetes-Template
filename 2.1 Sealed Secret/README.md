Here’s a comprehensive document explaining how to use **Kubernetes Sealed Secrets**, including a **demo deployment of a Spring Boot API** on a **local KinD cluster**.

---

# **Using Kubernetes Sealed Secrets with a Spring Boot API on KinD**

## **Overview**

Kubernetes Sealed Secrets allow you to safely store encrypted secrets in version control. They are decrypted only by the controller running inside your cluster. This is ideal for CI/CD pipelines and secure configuration management.

---

## **1. Prerequisites**

- Docker
- KinD (Kubernetes in Docker)
- `kubectl`
- kubeseal CLI
- Spring Boot application (simple REST API)
- Sealed Secrets controller installed in KinD

---

## **2. Set Up KinD Cluster**

Create a KinD cluster:
```bash
kind create cluster --name sealed-demo
```

Verify:
```bash
kubectl cluster-info --context kind-sealed-demo
```

---

## **3. Install Sealed Secrets Controller**

Install the controller in the KinD cluster:
```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
```

Wait for the controller to be ready:
```bash
kubectl get pods -n kube-system | grep sealed-secrets
```

---

## **4. Create a Kubernetes Secret**

Create a generic secret:
```bash
kubectl create secret generic spring-secret \
  --from-literal=db-password=supersecret \
  --dry-run=client -o yaml > spring-secret.yaml
```

---

## **5. Seal the Secret**

Fetch the public key from the controller:
```bash
kubeseal --fetch-cert \
  --controller-namespace kube-system \
  > pub-cert.pem
```

Seal the secret:
```bash
kubeseal --cert pub-cert.pem < spring-secret.yaml > sealed-secret.yaml
```

This `sealed-secret.yaml` can now be safely committed to version control.

---

## **6. Spring Boot Deployment YAML**

Here’s a sample `deployment.yaml` for a Spring Boot API:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: spring-api
  template:
    metadata:
      labels:
        app: spring-api
    spec:
      containers:
        - name: spring-api
          image: your-dockerhub/spring-api:latest
          env:
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: spring-secret
                  key: db-password
          ports:
            - containerPort: 8080
```

---

## **7. Apply Sealed Secret and Deploy**

Apply the sealed secret:
```bash
kubectl apply -f sealed-secret.yaml
```

Apply the deployment:
```bash
kubectl apply -f deployment.yaml
```

Expose the service:
```bash
kubectl expose deployment spring-api --type=NodePort --port=8080
```

Get the port:
```bash
kubectl get service spring-api
```

Access the API:
```bash
curl http://localhost:<NodePort>
```

---

## **8. Summary**

| Component         | Purpose                                      |
|------------------|----------------------------------------------|
| Sealed Secrets    | Securely store secrets in Git               |
| KinD              | Local Kubernetes cluster                    |
| Spring Boot API   | Sample application using secret injection   |
| kubeseal CLI      | Encrypt secrets using cluster's public key  |

---

Would you like this exported as a **PDF or Word document**, or bundled with the previous documents? I can also generate a sample Spring Boot project structure if needed.
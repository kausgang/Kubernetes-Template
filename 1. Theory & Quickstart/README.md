# 🧩 **Week 1 Kubernetes Tutorial**

## **Deploying Your First API to Kubernetes**

Welcome to Week 1! This week focuses on foundational Kubernetes concepts and hands-on practice. By the end of this module you will:

✅ Understand the Kubernetes architecture
✅ Learn deployment strategies
✅ Work with `kubectl` & YAML manifests
✅ Deploy your first REST API with multiple replicas

---

# 1. 🔍 **Deep Dive into Kubernetes Architecture**

Kubernetes (K8s) is a container orchestration system that automates deployment, scaling, and management of containerized apps.

## **1.1 Control Plane Components**

This is the “brain” of Kubernetes.

### **API Server**

- Central communication hub
- All commands (`kubectl`), controllers, and nodes talk to it

### **etcd**

- Distributed key-value store
- Holds cluster state (nodes, pods, configs)

### **Scheduler**

- Decides **which node** runs a new pod based on resource needs

### **Controller Manager**

- Runs background controllers:

  - Node Controller
  - Deployment Controller
  - ReplicaSet Controller
  - Job Controller

- Ensures desired cluster state matches actual state

## **1.2 Worker Nodes**

Nodes run your actual application containers.

### **Node Components**

**Kubelet**

- Talks to API server
- Ensures containers on the node are running

**Kube-proxy**

- Manages networking & load balancing per node

**Container Runtime**

- Docker, containerd, CRI-O
- Responsible for pulling/running containers


### Check out the pods responsible for these components 

```batch

C:\Users\typgang>kubectl get pods --namespace kube-system
NAME                                                  READY   STATUS    RESTARTS   AGE
coredns-66bc5c9577-8pvrq                              1/1     Running   0          3m29s
coredns-66bc5c9577-nfwq8                              1/1     Running   0          3m29s
etcd-kind-cluster1-control-plane                      1/1     Running   0          3m36s
kindnet-vffp9                                         1/1     Running   0          3m29s
kube-apiserver-kind-cluster1-control-plane            1/1     Running   0          3m36s
kube-controller-manager-kind-cluster1-control-plane   1/1     Running   0          3m36s
kube-proxy-nqpt6                                      1/1     Running   0          3m29s
kube-scheduler-kind-cluster1-control-plane            1/1     Running   0          3m36s

C:\Users\typgang>
```

---

# 2. 🔄 **Deployment Strategies in Kubernetes**

Kubernetes supports multiple release strategies:

### **2.1 Rolling Updates (Default)**

- Gradually replace old pods with new ones
- Zero downtime

```
kubectl rollout restart deployment my-api
```

### **2.2 Blue-Green Deployment**

- Two environments: _Blue_ (current) and _Green_ (new)
- Traffic switch happens instantly via Service update

### **2.3 Canary Deployment**

- Release new version to a small % of users
- Analyze → gradually increase rollout

Canary example using labels:

```
kubectl set image deployment/my-api my-api=myimage:v2 --record
```

---

# 3. 🧰 **kubectl Commands & YAML Basics**

### **3.1 Common kubectl Commands**

| Action          | Command                       |
| --------------- | ----------------------------- |
| View nodes      | `kubectl get nodes`           |
| View pods       | `kubectl get pods`            |
| Describe pod    | `kubectl describe pod <name>` |
| Apply YAML      | `kubectl apply -f file.yaml`  |
| Delete resource | `kubectl delete -f file.yaml` |

### **3.2 Basic YAML Structure**

Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-api
  template:
    metadata:
      labels:
        app: my-api
    spec:
      containers:
        - name: my-api
          image: my-api:latest
          ports:
            - containerPort: 5000
```

Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-api-service
spec:
  type: LoadBalancer
  selector:
    app: my-api
  ports:
    - port: 80
      targetPort: 5000
```

---

# 4. 🚀 **Practice Project: Deploy a Python Flask REST API**

You will build a simple Flask API, containerize it, write Kubernetes manifests, and deploy it with multiple replicas.

---

# 4.1 📁 **Create the Project Structure**

```
k8s-api/
 ├── app.py
 ├── requirements.txt
 ├── Dockerfile
 ├── deployment.yaml
 ├── service.yaml
 └── README.md
```

---

# 4.2 🧪 **Python Flask API (app.py)**

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/api")
def api():
    return jsonify({"message": "Hello from Kubernetes!"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

# 4.3 📦 **requirements.txt**

```
Flask==3.0.0
```

---

# 4.4 🐳 **Dockerfile**

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY . .
RUN pip install -r requirements.txt

EXPOSE 5000
CMD ["python", "app.py"]
```

---

# 4.5 🏗️ **Build & Push Your Docker Image**

Replace `<your-dockerhub-username>`:

```bash
docker build -t <your-dockerhub-username>/k8s-flask-api:v1 .
docker push <your-dockerhub-username>/k8s-flask-api:v1
```

---

# 4.6 📜 **Kubernetes Deployment Manifest (deployment.yaml)**

There are different ways to generate manifest templates. [See this note](./Resources/Template%20generation.md)

Below is an example command to generate a simple deployment with image `iem22/purchase:latest`

`kubectl create deployment test-deployment --image=iem22/purchase:latest --dry-run=client -o yaml > deployment.yaml`

there are online tools as well like this - https://k8syaml.com/


```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask-api
  template:
    metadata:
      labels:
        app: flask-api
    spec:
      containers:
        - name: flask-api
          image: <your-dockerhub-username>/k8s-flask-api:v1
          ports:
            - containerPort: 5000
          readinessProbe:
            httpGet:
              path: /health
              port: 5000
            initialDelaySeconds: 2
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /health
              port: 5000
            initialDelaySeconds: 5
            periodSeconds: 10
```

---

# 4.7 🌐 **Service Manifest (service.yaml)**


Choose service type based on your environment:

- **ClusterIP** (internal only)
- **NodePort** (access via node’s IP + port)
- **LoadBalancer** (cloud providers)

There are easy ways to generate service with kubectl command or online tool. Below is an example - 

`kubectl expose deployment my-deployment --type=NodePort --port=80 --name=my-service --dry-run=client -o yaml > service.yaml`

> you can deploy an Ingress controller and use it with a ClusterIP Service to expose your application, which is generally a better practice than creating a manual service for external access. In a kind cluster, you can also use a software-based load balancer like MetalLB or the cloud-provider-kind tool to simulate a LoadBalancer service type

> By default, the LoadBalancer service type in Kubernetes is intended for cloud environments (AWS, GCP, Azure, etc.) that have native load balancer support. A local kind cluster does not have this functionality built-in, so a service of type LoadBalancer will remain in a "pending" state


```yaml
apiVersion: v1
kind: Service
metadata:
  name: flask-api-service
spec:
  type: LoadBalancer
  selector:
    app: flask-api
  ports:
    - port: 80
      targetPort: 5000
```

---

# 4.8 🚀 **Deploy to Kubernetes**

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

Check resources:

```bash
kubectl get pods
kubectl get svc
kubectl logs -f <pod-name>
```

---

# 4.9 🌍 **Access the API**

If service type is LoadBalancer:

```bash
curl http://<external-ip>/api
```

If NodePort:

```bash
curl http://<node-ip>:<nodeport>/api
```

---

# 🎯 **End of Week 1 Goals Achieved**

You have:

✔ Understood Kubernetes architecture
✔ Learned deployment strategies
✔ Used `kubectl` and YAML
✔ Built and deployed a Python REST API
✔ Scaled it to multiple replicas
✔ Added health checks

---

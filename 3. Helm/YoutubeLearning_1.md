https://www.youtube.com/watch?v=DQk8HOVlumI

# Helm Chart Tutorial - Chapters 3 & 4

## Chapter 3: Essential Helm Commands

### 3.1 helm create

Creates a new Helm chart with default templates.

```bash
helm create <chart-name>
```

**Example:**

```bash
helm create hello-world
```

---

### 3.2 helm install

Installs a chart into your Kubernetes cluster.

```bash
helm install <release-name> <chart-directory>
```

**Example:**

```bash
helm install my-hello-world-release hello-world
```

---

### 3.3 helm list

Lists all deployed releases.

```bash
helm list -a
```

Shows release name, revision, status, and chart version.

---

### 3.4 helm upgrade

Upgrades a release with new changes. Increments revision number.

```bash
helm upgrade <release-name> <chart-directory>
```

**Example:**

```bash
# Edit values.yaml (e.g., change replica count)
vi hello-world/values.yaml

# Apply the upgrade
helm upgrade my-hello-world-release hello-world
```

---

### 3.5 helm rollback

Rolls back to a previous revision.

```bash
helm rollback <release-name> <revision-number>
```

**Example:**

```bash
helm rollback my-hello-world-release 1
```

**Note:** Rollback creates a new revision (e.g., revision 3 after rolling back to revision 1).

---

### 3.6 helm install --debug --dry-run

Tests and debugs your chart without installing it.

```bash
helm install <release-name> <chart-directory> --debug --dry-run
```

This validates your chart against Kubernetes and shows what will be deployed.

---

### 3.7 helm template

Renders templates locally without connecting to Kubernetes.

```bash
helm template <chart-directory>
```

Useful for previewing final YAML output before deployment.

---

### 3.8 helm lint

Validates chart for errors and best practices.

```bash
helm lint <chart-directory>
```

**Example:**

```bash
helm lint hello-world
```

Output: "1 chart(s) linted, 0 chart(s) failed" indicates success.

---

### 3.9 helm uninstall

Removes a release from Kubernetes.

```bash
helm uninstall <release-name>
```

---

## Chapter 4: Creating a Custom Python Application Chart

### 4.1 Overview

In this chapter, you'll create a complete workflow:

1. Build a Python Flask REST API
2. Create a Docker container
3. Push to Docker Hub
4. Create a Helm chart
5. Deploy to Kubernetes

---

### 4.2 Python Flask Application

#### Create main.py

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/hello', methods=['GET'])
def hello_world():
    return jsonify({'message': 'Hello World'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9001)
```

#### Create requirements.txt

```txt
Flask==2.0.1
```

---

### 4.3 Create Dockerfile

```dockerfile
FROM python:3.8
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python", "main.py"]
```

---

### 4.4 Build and Test Docker Image

#### Step 1: Build Image

```bash
docker build -t python-project .
```

#### Step 2: Run Locally

```bash
docker run -p 9001:9001 python-project
```

#### Step 3: Test

Open browser and navigate to:

```
http://localhost:9001/hello
```

You should see: `{"message": "Hello World"}`

---

### 4.5 Push to Docker Hub

#### Step 1: Login to Docker Hub

```bash
docker login
```

#### Step 2: Tag Image

```bash
docker tag python-project <your-username>/python-flask-rest-api-project
```

#### Step 3: Push to Docker Hub

```bash
docker push <your-username>/python-flask-rest-api-project
```

---

### 4.6 Create Helm Chart

#### Step 1: Create Chart

```bash
helm create python-flask-rest-api-project
```

#### Step 2: Edit Chart.yaml

Comment out appVersion:

```bash
vi python-flask-rest-api-project/Chart.yaml
```

```yaml
# appVersion: "1.16.0"
```

#### Step 3: Edit values.yaml

Update repository and service type:

```bash
vi python-flask-rest-api-project/values.yaml
```

```yaml
image:
  repository: <your-username>/python-flask-rest-api-project

service:
  type: NodePort
  port: 9001
```

#### Step 4: Edit deployment.yaml

Update container port and remove probes:

```bash
vi python-flask-rest-api-project/templates/deployment.yaml
```

Change `containerPort` to `9001` and comment out `livenessProbe` and `readinessProbe` sections.

---

### 4.7 Deploy to Kubernetes

#### Step 1: Install Chart

```bash
helm install my-python-helm-chart python-flask-rest-api-project
```

#### Step 2: Verify Deployment

```bash
helm list -a
kubectl get deployments
kubectl get service
```

#### Step 3: Access Application

Get your machine IP and NodePort:

```bash
hostname -I
```

Access in browser:

```
http://<YOUR-IP>:<NODE-PORT>/hello
```

You should see your Flask API response: `{"message": "Hello World"}`

---

## Summary

**Chapter 3** covered all essential Helm commands you need for daily chart management - from creating and installing charts to upgrading, rolling back, debugging, and uninstalling.

**Chapter 4** provided hands-on experience building a complete application pipeline: creating a Python Flask REST API, containerizing it with Docker, pushing to Docker Hub, creating a custom Helm chart, and deploying it to a Kubernetes cluster.

These chapters build the foundation for working with Helm charts in real-world scenarios, preparing you to manage complex deployments and create custom charts for your applications.

Absolutely! Here's a comprehensive tutorial and reference document focused on **Helm** for packaging and deploying your Spring Boot API using Helm charts.

---

## 📘 Tutorial: Packaging APIs with Helm Charts

### **Overview**
Helm is a package manager for Kubernetes that simplifies deployment and management of applications. This tutorial covers:

- Helm basics: charts, values, templates
- Creating custom Helm charts
- Helm hooks and dependencies
- Chart repositories

---

### **1. Helm Basics**

#### 🔹 What is a Helm Chart?
A Helm chart is a collection of files that describe a related set of Kubernetes resources.

**Chart Structure:**
```
my-api-chart/
├── Chart.yaml          # Metadata about the chart
├── values.yaml         # Default configuration values
├── templates/          # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl
```

#### 🔹 Installing Helm
```bash
brew install helm  # macOS
choco install kubernetes-helm  # Windows
```

---

### **2. Creating Custom Helm Charts**

#### 🔹 Create a Chart
```bash
helm create my-api-chart
```

This generates a scaffold with default templates.

#### 🔹 Customize Templates

**templates/deployment.yaml** (snippet):
```yaml
spec:
  replicas: {{ .Values.replicaCount }}
  containers:
    - name: {{ .Chart.Name }}
      image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
      env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: {{ .Values.secrets.name }}
              key: DB_USER
```

---

### **3. Helm Hooks and Dependencies**

#### 🔹 Helm Hooks
Hooks allow you to run tasks at specific points in the release lifecycle.

**Example: Job Hook**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-db-migration"
  annotations:
    "helm.sh/hook": pre-install
spec:
  template:
    spec:
      containers:
        - name: migrate
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          command: ["java", "-jar", "app.jar", "migrate"]
      restartPolicy: Never
```

#### 🔹 Dependencies
You can define dependencies in `Chart.yaml`:

```yaml
dependencies:
  - name: postgresql
    version: 10.3.11
    repository: "https://charts.bitnami.com/bitnami"
```

Then run:
```bash
helm dependency update
```

---

### **4. Chart Repositories**

You can publish your chart to a Helm repository or use a private one.

**Add a repo:**
```bash
helm repo add myrepo https://myrepo.example.com/charts
helm repo update
```

**Package your chart:**
```bash
helm package my-api-chart
```

**Push to repo (using chartmuseum or GitHub Pages):**
```bash
curl --data-binary "@my-api-chart-0.1.0.tgz" http://myrepo.example.com/api/charts
```

---

## 🛠️ Practice Project: Helm Chart for Spring Boot API

### **Goal**
Create a Helm chart for your Spring Boot API with configurable:

- Replicas
- Resource limits
- Environment variables

---

### **1. values.yaml (Environment Specific)**

```yaml
replicaCount: 2

image:
  repository: my-springboot-api
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 8080

resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
  requests:
    cpu: "250m"
    memory: "256Mi"

env:
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_USER
  - name: DB_PASS
    valueFrom:
      secretKeyRef:
        name: db-credentials
        key: DB_PASS

secrets:
  name: db-credentials
```

Create separate files like `values-dev.yaml`, `values-staging.yaml`, `values-prod.yaml` with different values.

---

### **2. Deploy with Helm**

**Install:**
```bash
helm install my-api-release ./my-api-chart -f values-dev.yaml
```

**Upgrade:**
```bash
helm upgrade my-api-release ./my-api-chart -f values-prod.yaml
```

**Uninstall:**
```bash
helm uninstall my-api-release
```

---

## 📎 Reference Summary

| Concept | Description | File |
|--------|-------------|------|
| Chart | Package of Kubernetes manifests | `Chart.yaml` |
| Values | Configurable parameters | `values.yaml` |
| Templates | Parameterized manifests | `templates/*.yaml` |
| Hooks | Lifecycle events | `helm.sh/hook` annotations |
| Dependencies | External charts | `Chart.yaml` |
| Repositories | Chart hosting | GitHub Pages, ChartMuseum |

---

Would you like me to generate a sample Helm chart structure for your Spring Boot API, including templates and values files for dev/staging/prod?
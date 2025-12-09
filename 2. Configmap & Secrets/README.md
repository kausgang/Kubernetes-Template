Great! Let's break this down into a comprehensive tutorial and reference document, followed by a practice project using Spring Boot and Kubernetes with a local **Kind** cluster.

---

## 📘 Tutorial: Managing API Configuration in Kubernetes

### **Overview**
In Kubernetes, managing application configuration externally from the codebase is a best practice. This tutorial covers:

- **ConfigMaps** and **Secrets**
- **Environment Variable Injection**
- **Volume Mounts for Configuration Files**

---

### **1. ConfigMaps and Secrets**

#### 🔹 ConfigMaps
Used to store non-sensitive configuration data as key-value pairs.

**Create a ConfigMap:**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: api-config
data:
  APP_NAME: "MySpringBootApp"
  LOG_LEVEL: "DEBUG"
```

**Apply:**
```bash
kubectl apply -f configmap.yaml
```

#### 🔹 Secrets
Used to store sensitive data like passwords, tokens, etc.

**Create a Secret:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  DB_USER: bXl1c2Vy  # base64 encoded 'myuser'
  DB_PASS: bXlwYXNz  # base64 encoded 'mypass'
```

**Apply:**
```bash
kubectl apply -f secret.yaml
```

---

### **2. Environment Variable Injection**

Inject ConfigMap and Secret values into your container:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: springboot-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: springboot-api
  template:
    metadata:
      labels:
        app: springboot-api
    spec:
      containers:
      - name: api-container
        image: my-springboot-api:latest
        env:
        - name: APP_NAME
          valueFrom:
            configMapKeyRef:
              name: api-config
              key: APP_NAME
        - name: LOG_LEVEL
          valueFrom:
            configMapKeyRef:
              name: api-config
              key: LOG_LEVEL
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
```

---

### **3. Volume Mounts for Configuration**

You can mount ConfigMaps or Secrets as files:

```yaml
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      volumes:
      - name: config-volume
        configMap:
          name: api-config
```

This will mount each key in the ConfigMap as a file under `/etc/config`.

---

## 🛠️ Practice Project: Spring Boot API with DB Connectivity

### **Step-by-Step Guide**

#### **1. Create Spring Boot API**

Use Spring Initializr with:

- Dependencies: Spring Web, Spring Data JPA, PostgreSQL Driver
- Application Properties:
```properties
spring.datasource.url=jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:mydb}
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASS}
spring.jpa.hibernate.ddl-auto=update
```

#### **2. Dockerize the Application**

**Dockerfile:**
```Dockerfile
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/myapp.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

Build the image:
```bash
docker build -t my-springboot-api .
```

#### **3. Create Kind Cluster**

```bash
kind create cluster --name springboot-demo
```

#### **4. Apply ConfigMap and Secret**

Use the YAML files from the tutorial above.

#### **5. Deploy to Kind**

Use the deployment YAML from the tutorial. Make sure to push your Docker image to a local registry or load it into Kind:

```bash
kind load docker-image my-springboot-api --name springboot-demo
kubectl apply -f deployment.yaml
```

#### **6. Verify Deployment**

```bash
kubectl get pods
kubectl logs <pod-name>
kubectl port-forward svc/springboot-api 8080:8080
```

Access your API at `http://localhost:8080`.

---

## 📎 Reference Summary

| Feature | Purpose | Kubernetes Resource | Usage |
|--------|---------|---------------------|-------|
| ConfigMap | Store non-sensitive config | `ConfigMap` | Inject via env vars or volume |
| Secret | Store sensitive data | `Secret` | Inject via env vars or volume |
| Env Injection | Pass config to app | `env` in Deployment | `valueFrom` |
| Volume Mount | Mount config as files | `volumes` + `volumeMounts` | `/etc/config` |

---

Would you like me to generate the Spring Boot project structure and Dockerfile for you? Or perhaps create the YAML files for deployment and configuration?
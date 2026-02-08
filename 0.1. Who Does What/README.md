# Kubernetes Microservices Deployment — Team Structure & Responsibility Guide

**Author:** Kaustav Ganguli (Consultant, Trenton)  
**Audience:** Engineering, Platform, SRE/Operations, Security, DBA, Networking  
**Version:** 1.0  
**Last Updated:** Feb 8, 2026

---

## Purpose

This document outlines a **typical team structure** and **responsibility distribution** for deploying microservices on Kubernetes. It covers the lifecycle from **code development and containerization**, through **cluster creation**, **application deployment**, **exposing services via Gateway API**, **security management**, **backup & restore**, **logging & authentication (“login management”)**, and more.

Assumptions:

- The application database is **outside** the Kubernetes cluster.
- There is an **Application Development** team and a **Deployment** team; additional roles are recommended below.
- Targets **Dev**, **Test**, **Stage**, **Prod** environments.

---

## Recommended Team Structure

> Adjust titles to match your org. Smaller orgs may combine roles; larger orgs may split further.

1. **Application Development (Feature Teams)**
   - Build microservices, APIs, front-end apps.
   - Own business logic, API contracts, unit/component tests.
   - Define resource needs, readiness/liveness probes.
   - Provide Dockerfiles, Helm/Kustomize templates in collaboration with Platform.

2. **Platform / DevOps (Kubernetes Platform Team)**
   - Design, build, and operate Kubernetes **platform as a product**.
   - Cluster provisioning, upgrades, add-ons (CNI, CSI), ingress/gateway controllers.
   - CI/CD pipelines, artifact repositories, image registries, base images, build runners.
   - Multi-tenancy, namespaces, quotas, RBAC, secrets mechanisms.
   - Templates and golden paths (Helm charts, Operators).
   - Cost & capacity management.

3. **SRE / Operations**
   - Reliability engineering, **SLIs/SLOs**, error budgets.
   - Incident response, on-call, runbooks, DR playbooks.
   - Observability stack (logs, metrics, traces), alerting.
   - Performance/load testing coordination.
   - Backups/restores (**etcd**, persistent volumes), cluster and node health.

4. **Security / GRC**
   - Security policies, RBAC, workload identity, image signing/scanning (supply chain security).
   - Secrets management, key rotation, vault governance.
   - Network policies (zero trust), admission controls (OPA/Gatekeeper/Kyverno).
   - Compliance (SOC2/ISO27001/PCI), audits, third-party risk.

5. **Networking**
   - VPC/VNet design, subnets, routing, firewalls, service connectivity.
   - Private ingress/egress, WAF, API gateways, Gateway API configuration standards.
   - Connectivity to **external databases** (peering, VPN, private links).

6. **Database / Data Platform**
   - Own DB lifecycle, schema changes, performance, backups, DR.
   - Connection endpoints, TLS certs, rotation policies.
   - Provide connection guidelines (drivers, parameters, retry/backoff).

7. **QA / Test Engineering**
   - Test plans, functional/integration/e2e tests, performance & security tests.
   - Test data management and environment readiness.

8. **Release & Change Management**
   - Release cadences, approvals, deployment windows.
   - Change tickets, rollback criteria, versioning.

9. **Product Management**
   - Prioritization, scope, cross-team coordination (especially for breaking API changes).

---

## Responsibility by Topic (What’s owned by which team)

### 1) **Code Development & Containerization**
- **Dev**: Write code, unit tests; Dockerfiles (or use Platform base images); health probes.
- **Platform**: Provide hardened base images, CI templates, build runners, registries, SAST/DAST integration.
- **Security**: Enforce policies (dependencies, SBOMs, image signing).
- **SRE**: Define operational requirements (readiness, resource requests/limits).

### 2) **Cluster Creation & Maintenance**
- **Platform**: Provision clusters (cloud-managed or self-managed), manage upgrades (K8s version, CNI/CSI), add-ons (Ingress/Gateway controller, service mesh), node pools, autoscaling.
- **SRE**: Monitor cluster health, capacity, and performance.
- **Security**: Baseline hardening, CIS benchmarks, audit logging.

### 3) **Application Deployment (Helm/Kustomize/Operators)**
- **Platform**: Provide deployment templates and best practices; CI/CD pipeline integration; progressive delivery (canary/blue-green).
- **Dev**: Own manifests (values, resource configs) within provided templates; validate runtime behavior.
- **SRE**: Rollout strategies, gates, and rollback procedures.

### 4) **Service Exposure (Gateway API / Ingress / API Gateway)**
- **Networking** & **Platform**: Operate and configure gateway controllers (e.g., Envoy, NGINX, Kong, Istio), WAF, TLS termination, routing policies, rate-limits.
- **Dev**: Specify routes, hostnames, paths, versions; define API contracts and docs.
- **Security**: AuthN/AuthZ policies, mTLS, JWT/OAuth2, DDoS protections.

### 5) **Security Management**
- **Security**: Ownership of policy-as-code (OPA/Kyverno), image scanning (e.g., Trivy/Anchore), SBOMs, signing (Cosign), secrets handling standards, vulnerability management.
- **Platform**: Integrate scanners/admission controllers; manage Vault/Secrets store; provide workload identity.
- **Dev**: Fix vulnerabilities; follow secure coding; use secret mounts and workload identity (not hardcoded secrets).
- **SRE**: Runtime security monitoring; incident response playbooks.

### 6) **Backup & Restore**
- **SRE**: Backups of cluster state (**etcd**), persistent volumes (via CSI snapshot/Velero), restore drills.
- **Platform**: Tooling selection and integrations (Velero, snapshots).
- **DBA**: Backups & DR for the external database.

### 7) **Observability: Logging, Metrics, Tracing**
- **Platform/SRE**: Centralized log stack (e.g., OpenSearch/ELK), metrics (Prometheus/Grafana), tracing (OpenTelemetry), alerting.
- **Dev**: Emit structured logs, traces, custom metrics; define dashboards for service health.
- **Security**: Log retention, access control, audit trails.

> **Note:** You mentioned “login management.” This typically maps to **Identity & Access Management** for users (SSO, OAuth2/OIDC), plus **authentication** between services (mTLS/JWT). Logging (observability) is separate.

### 8) **Identity & Access (“Login Management”)**
- **Security/IAM**: Choose and operate IdP (Azure AD, Okta, Keycloak), RBAC policies, MFA requirements.
- **Platform**: Integrate cluster/workload identity; manage service accounts & roles.
- **Dev**: Integrate OIDC/OAuth2 libraries, session/token handling, role checks in code.
- **SRE**: Monitor auth service SLAs, incident handling for auth outages.

### 9) **Networking (Inside/Outside Cluster)**
- **Networking**: VPC/VNet design, peering/VPN/MPLS, firewall rules, NAT, private links to external systems (e.g., DB).
- **Platform**: CNI configuration, NetworkPolicies, service mesh setup.
- **Security**: Segmentation, zero trust, TLS/mTLS policies.

### 10) **Compliance & Governance**
- **Security/GRC**: Data classification, encryption standards, retention, audit evidence.
- **Platform/SRE**: Control implementations (logs, access reviews).
- **Dev**: Adherence to secure coding and data handling requirements.

### 11) **Cost Management**
- **Platform/SRE**: Resource requests/limits, autoscaling, bin packing, cost dashboards.
- **Product**: Budget alignment.
- **Dev**: Performance optimizations and resource efficiency.

---

## Database Outside the Cluster — Who Manages Connection?

**Recommended split of responsibilities:**

- **Database/Data Platform (DBA):**
  - Owns the **database endpoint**, auth models (user/service accounts), **TLS certs**, connection policies, backups/DR, performance tuning.
  - Provides connection requirements (TLS modes, CA bundle, connection strings format, retry strategies).

- **Networking:**
  - Ensures **secure connectivity** from the cluster to the database:
    - **VPC/VNet peering**, **VPN**, **Private Link/Endpoint**, firewall rules, routing.
    - IP allowlists, NAT, DNS.

- **Security/IAM:**
  - Approves **credential model** (managed identities, short-lived tokens, dynamic secrets).
  - Defines rotation policies and audit requirements.

- **Platform/DevOps:**
  - Integrates connection details into the **secrets management** workflow:
    - External Secrets Operator (ESO), Vault, or cloud secret managers.
    - Workload identity configuration (e.g., Azure Workload Identity, GCP/AWS equivalents).
  - Provides a **standard pattern** (sidecars, init containers, cert mounts, CA bundles).

- **Application Development:**
  - Implements the **connection logic** in code:
    - Uses drivers/ORMs correctly, TLS verification, pooling, retries/backoff.
    - **Never** hardcodes credentials; pulls them via environment variables, files, or workload identity.
    - Observability hooks (connection latency, error rates, pool saturation).

**Short Answer:**  
- **DBA + Networking** create and secure the **path and endpoint**.  
- **Platform/Security** manage **secrets/identity and rotation**.  
- **Application Dev** consumes the connection via approved patterns and owns **runtime usage** and error handling.

---

## RACI Matrix (Abbreviated)

| Activity | Dev | Platform | SRE | Security | Networking | DBA | QA | Release |
|---|---|---|---|---|---|---|---|---|
| Dockerfile & app code | **R** | C | C | C | - | - | C | - |
| CI/CD pipelines | C | **A/R** | C | C | - | - | C | C |
| Cluster provisioning/upgrades | - | **A/R** | C | C | C | - | - | - |
| Helm/Kustomize templates | C | **A/R** | C | C | - | - | - | - |
| Gateway API / Ingress | C | **R** | C | C | **A** | - | - | - |
| Secrets & workload identity | C | **R** | C | **A** | - | - | - | - |
| Image scanning & admission | - | R | C | **A** | - | - | - | - |
| App deployment (prod) | C | R | **A** | C | C | - | C | **A** |
| Observability stack | C | R | **A** | C | - | - | - | - |
| Backups (etcd/PVs) | - | R | **A** | C | - | - | - | - |
| DB backups | - | - | - | C | - | **A/R** | - | - |
| DB connectivity (network path) | - | C | C | C | **A/R** | C | - | - |
| DB connection usage in app | **A/R** | C | C | C | - | C | C | - |
| Security compliance | C | C | C | **A/R** | C | C | - | - |
| Performance/load tests | **R** | C | **A** | C | C | C | **A/R** | - |
| Release/change approvals | C | C | C | C | C | C | C | **A/R** |

**Legend:** A = Accountable, R = Responsible, C = Consulted, - = Not Involved

---

## End-to-End Lifecycle Checklist

### A) Plan & Design
- [ ] Architecture documented (services, APIs, data flow, dependencies).
- [ ] Non-functional requirements: availability, latency, capacity, security.
- [ ] SLOs/SLIs drafted (SRE), compliance requirements (Security/GRC).

### B) Build & Containerize
- [ ] Dockerfile follows best practices (non-root, minimal base image, multi-stage build).
- [ ] SBOM generated; vulnerabilities scanned; images signed.
- [ ] Unit tests + component tests in CI.

### C) Define Deployment
- [ ] Helm/Kustomize manifests with resource limits/requests, probes, HPA.
- [ ] ConfigMaps & Secrets (via Vault/ESO) defined; no secrets in Git.
- [ ] ServiceAccount, RBAC, NetworkPolicies.

### D) Networking & Exposure
- [ ] Gateway API routes/HTTPRoutes/TLS configured.
- [ ] WAF rules, rate limiting, mTLS/JWT policies.
- [ ] Private connectivity to external DB established (peering/VPN/Private Link).

### E) Security
- [ ] Admission controls (Kyverno/OPA) enforce policies.
- [ ] Image scanning; dependency scanning; license compliance.
- [ ] Workload identity configured; secret rotation schedule agreed.

### F) Observability & Readiness
- [ ] Logs/metrics/traces instrumented; dashboards and alerts defined.
- [ ] Runbooks for common failures; synthetic monitoring in place.

### G) Testing
- [ ] Functional/integration/e2e tests pass.
- [ ] Performance/load tests; resilience tests (pod/node failures).
- [ ] Security tests (DAST, pen tests where applicable).

### H) Backup & DR
- [ ] etcd backup policy defined; PV backup policy configured (Velero).
- [ ] DB backup/restore verified (DBA).
- [ ] DR RTO/RPO targets and drill schedule.

### I) Release & Operate
- [ ] Change ticket approved; deployment window set.
- [ ] Progressive delivery (canary/blue-green) plan and rollback path.
- [ ] Post-deploy health checks; SLO monitoring; error budget tracking.

---

## Patterns & Reference Implementations

- **Secrets**: External Secrets Operator + Vault/Cloud KMS; short-lived tokens or workload identity over static secrets.
- **Gateway API**: Prefer Gateway API over legacy Ingress for richer routing and policy expressions; central controllers managed by Platform/Networking.
- **Service Mesh (optional)**: Istio/Linkerd for mTLS, traffic shaping, and observability—owned by Platform, with config contributions from Dev and Security.
- **Progressive Delivery**: Argo Rollouts or Flagger with canary/blue-green; guardrails via Prometheus metrics.
- **GitOps (optional)**: Argo CD/Flux for environment drift control and auditability.

---

## Common Gaps You Might Have Missed

- **Supply Chain Security**: SBOMs, image signing (Cosign), provenance (SLSA).
- **Admission Policy**: Enforcing resource limits, non-root users, approved registries only.
- **Workload Identity**: Avoid long-lived credentials; use IAM-bound service accounts.
- **NetworkPolicies**: Default deny; explicit allow between namespaces/services.
- **Rate Limiting & DDoS Controls**: At gateway and upstream.
- **TLS Everywhere**: Ingress, service-to-service, DB connection.
- **Cost Governance**: Quotas, autoscaling, rightsizing, chargeback/showback.
- **Runbooks & GameDays**: Practice incident response & DR.
- **Config Management**: Separate config from code; environment-specific overlays.
- **Chaos & Resilience Testing**: Validate failure modes proactively.

---

## Example: Database Connection Ownership (Concrete)

- **Networking**: Creates **Private Link** from cluster VNet to DB, sets firewall rules, DNS.
- **DBA**: Issues **TLS-enabled endpoint**, CA cert, and a **service account** with least privilege; sets rotation every 90 days.
- **Security**: Approves rotation cadence and access policies; mandates workload identity where feasible.
- **Platform**: Configures **External Secrets** to fetch DB credentials from Vault; mounts CA bundle into pods; sets retries/backoff defaults.
- **Dev**: Uses ORM with `sslmode=verify-full`, connection pooling, circuit breaker; exposes metrics (`db_connection_errors`, `pool_in_use`, `latency_ms`).

---

## Appendices

### Appendix A: Minimal Helm Values Snippet (Illustrative)
```yaml
replicaCount: 3
resources:
  requests:
    cpu: "250m"
    memory: "512Mi"
  limits:
    cpu: "1"
    memory: "1Gi"
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
envFrom:
  - secretRef:
      name: db-credentials
serviceAccount:
  create: true
  name: svc-myapp
podSecurityContext:
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
networkPolicy:
  enabled: true
  defaultDeny: true
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

### Appendix B: Observability Expectations
- **Logs**: JSON, include request IDs, user/session IDs (if applicable), and error codes.
- **Metrics**: Latency, error rate (4xx/5xx), saturation, queue depth, DB pool metrics.
- **Traces**: Propagate trace context across services and to DB calls where supported.

---

## Final Notes

- If your **Deployment Team** already exists, it often maps to a combination of **Platform** + **SRE** in this model.
- Keep **“platform as a product”** mindset—provide paved roads, templates, and guardrails so Dev teams can ship safely and quickly.
- For the external DB, the safest split is: **DBA owns the database; Networking/Security/Platform make access secure and manageable; Dev owns how the app uses it.**

---

## Questions for You

- Do you already use **Gateway API** or an **Ingress Controller** (NGINX/Kong/Envoy/Istio)?  
- Are you leaning toward **workload identity** or **static secrets** for DB auth today?  
- Would a **template RACI** in Excel/CSV help you share this across teams?

If you want, I can turn this into a **Word or Markdown template** for your company’s internal wiki, or tailor it to your current toolchain (AKS/EKS/GKE, Vault vs cloud secrets, Argo vs Jenkins, etc.).
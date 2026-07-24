# 🚀 Local Multi-Node Kubernetes GitOps Pipeline (`my-k8s-gitops`)

A production-grade, local GitOps pipeline running on a 3-node **`kind`** Kubernetes cluster (`rkd01`). This architecture decouples **Day 0/1 Infrastructure as Code** (provisioned via **Terraform**) from **Day 2+ Application Delivery** (managed continuously via **ArgoCD**).

Infrastructure services are strictly isolated to a dedicated **Infrastructure Node** using Kubernetes node labels, taints, and tolerations.

---

## 🏗️ Architecture Overview

The cluster consists of **1 Control-Plane Node** and **2 Worker Nodes** with explicit workload isolation:

```text
                               +----------------------------------+
                               |     Windows Host Machine         |
                               +----------------------------------+
                                  |                     |
                  http://localhost:8080            http://localhost:30080
                  (Headlamp Dashboard)               (Webernetes App)
                                  |                     |
+-----------------------------------------------------------------------------------+
|  Kind Cluster: rkd01                                                              |
|                                                                                   |
|  +------------------------+  +------------------------+  +---------------------+  |
|  |  rkd01-control-plane   |  |      rkd01-worker      |  |    rkd01-worker2    |  |
|  +------------------------+  +------------------------+  +---------------------+  |
|  | - Cluster Control Plane|  | [Label: worker]        |  | [Label: infra]      |  |
|  | - API Server           |  |                        |  | [Taint: NoSchedule] |  |
|  | - Etcd / Scheduler     |  | - Webernetes Pod       |  |                     |  |
|  |                        |  |   (app-webernetes ns)  |  | - ArgoCD Engine     |  |
|  |                        |  |   Exposed: NodePort    |  |   (argocd ns)       |  |
|  |                        |  |   Port 30080           |  | - Headlamp UI       |  |
|  |                        |  |                        |  |   (headlamp ns)     |  |
|  +------------------------+  +------------------------+  +---------------------+  |
+-----------------------------------------------------------------------------------+

```




## 🗂️ Repository Folder Structure

```
my-k8s-gitops/
├── infrastructure-iac/               # Day 0/1: Infrastructure as Code (Terraform)
│   ├── cluster.yaml                  # Kind cluster multi-node configuration
│   ├── main.tf                       # Provider configurations (Helm & Kubernetes)
│   ├── argocd.tf                     # ArgoCD Helm deployment & Git Repo Secret
│   ├── variables.tf                  # GitHub authentication input declarations
│   └── terraform.tfvars              # Private credentials (git-ignored)
│
├── kubernetes-gitops/                # Day 2+: GitOps Engine Declarations (ArgoCD)
│   ├── bootstrap/                    # App-of-Apps root bootstrap pattern
│   │   └── infrastructure-apps.yaml  # ArgoCD Application declarations
│   ├── infrastructure/               # Cluster-wide platform services
│   │   └── headlamp/                 # Headlamp dashboard, service, & RBAC
│   │       ├── headlamp.yaml
│   │       └── rbac.yaml
│   └── apps/                         # Workloads & Business Applications
│       └── test-app/                 # Webernetes web app manifests
│           ├── namespace.yaml
│           └── deployment.yaml
│
└── README.md

```

## ⚙️ Workload Pinning & Isolation Matrix

| Node Name           | Node Label                                | Taint                                             | Target Workloads                     |
|---------------------|-------------------------------------------|--------------------------------------------------|--------------------------------------|
| rkd01-control-plane | node-role.kubernetes.io/control-plane     | System Default                                   | K8s Control Plane                    |
| rkd01-worker        | node-role.kubernetes.io/worker=""         | None                                             | Business Apps (webernetes-app)       |
| rkd01-worker2       | node-role.kubernetes.io/infra=""          | node-role.kubernetes.io/infra=reserved:NoSchedule | Infra Services (ArgoCD, Headlamp)    |


## 📋 Prerequisites

Ensure the following tooling is installed locally:

- **Docker Desktop** (or Docker Engine)  
- **kind** (Kubernetes in Docker CLI)  
- **kubectl**  
- **Terraform** (>= 1.0.0)  
- **Git**

---

## 🚀 Step-by-Step Deployment Guide

### Step 1: Clone the Repository

Run the following commands in your terminal:

```bash
git clone https://github.com/Ravikk-web/my-k8s-gitops.git
cd my-k8s-gitops

```

# Kubernetes GitOps Deployment Guide (Continued)

---


### Step 2: Provision the Local kind Cluster

Spin up the 3-node cluster using the `cluster.yaml` spec:

```bash
kind create cluster --config infrastructure-iac/cluster.yaml --name rkd01

```

# 🌐 Application Access & Port Matrix

| Service             | Access Method   | URL / Command                                                                 | Credentials / Token                                                                 |
|---------------------|-----------------|-------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| **ArgoCD UI**       | Port-Forward    | `kubectl port-forward svc/argocd-server -n argocd 8080:443`                   | **User:** admin <br> **Password:** `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" \| [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($null))` |
| **Headlamp Dashboard** | Port-Forward | `kubectl port-forward svc/headlamp -n headlamp 8080:80` <br> 👉 [http://localhost:8080](http://localhost:8080) | **Token:** `kubectl create token headlamp-admin -n headlamp`                        |
| **Webernetes App**  | Kind Native NodePort | 👉 [http://localhost:30080](http://localhost:30080)                          | Direct access (**No auth**)                                                         |



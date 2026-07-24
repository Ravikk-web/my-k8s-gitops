terraform {
  required_version = ">= 1.0.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
}

# The Helm provider will be used to deploy ArgoCD
provider "helm" {
  kubernetes {
    # This points to your local kubeconfig file
    config_path = "~/.kube/config"
    # Ensure this matches your Kind cluster name. 
    # If you ran `kind create cluster --name rkd01`, the context is `kind-gitops-cluster`
    config_context = "kind-gitops-cluster" 
  }
}

# The Kubernetes provider will be used to create the ArgoCD namespace and private repo secret
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-gitops-cluster"
}
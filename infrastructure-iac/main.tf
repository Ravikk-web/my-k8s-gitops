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
    config_path    = "~/.kube/config"
    config_context = "kind-rkd01" 
  }
}

# The Kubernetes provider will be used to create the ArgoCD namespace and private repo secret
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-rkd01" 
}
# Create the namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Deploy ArgoCD via Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    yamlencode({
      global = {
        nodeSelector = {
          "node-role.kubernetes.io/infra" = ""
        }
        tolerations = [
          {
            key      = "node-role.kubernetes.io/infra"
            operator = "Exists"
            effect   = "NoSchedule"
          },
          {
            key      = "infra-node"
            operator = "Exists"
            effect   = "NoSchedule"
          }
        ]
      }
      redis = {
        ha = {
          enabled = false
        }
      }
    })
  ]
}

# Register Private GitHub Repository in ArgoCD
resource "kubernetes_secret" "argocd_git_repo" {
  metadata {
    name      = "gitops-repo-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.github_repo_url
    username = var.github_username
    password = var.github_token
  }

  depends_on = [helm_release.argocd]
}
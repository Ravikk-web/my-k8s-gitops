variable "github_repo_url" {
  type        = string
  description = "https://github.com/Ravikk-web/my-k8s-gitops.git"
}

variable "github_username" {
  type        = string
  description = "Ravikk-web"
}

variable "github_token" {
  type        = string
  description = "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"
  sensitive   = true
}
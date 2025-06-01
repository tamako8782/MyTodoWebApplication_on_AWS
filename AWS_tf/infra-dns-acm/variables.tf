// global configuration
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "kustomize_bases_path" {
  description = "Path to the Kustomize base directory"
  type        = string
}
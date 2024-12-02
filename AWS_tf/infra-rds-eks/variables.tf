// global configuration
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

// for EC2
variable "key_name" {
  description = "Key pair name for EC2 instance maintenance"
  type        = string
}


//cluster version for EKS
variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.31"
}

// base name for EKS
variable "base_name" {
  description = "Base name for resource naming"
  type        = string
}

// EKS cluster name for EKS
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

// EKS managed node group name for EKS
variable "eks_managed_node_group_name" {
  description = "EKS managed node group name"
  type        = string
}


// repository name for ECR
variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
}

// CommonSetting for RDS
variable "identifier" {
  description = "RDS instance identifier"
  type        = string
  sensitive   = true
}
variable "instance_class" {
  description = "RDS instance class"
  type        = string
}
variable "engine" {
  description = "RDS engine"
  type        = string
}
variable "engine_version" {
  description = "RDS engine version"
  type        = string
}
variable "db_port" {
  description = "RDS port"
  type        = number
  default     = 3306
}

// first database name for RDS
variable "db_name" {
  description = "RDS first database name"
  type        = string
  sensitive   = true
}

// DB storage for RDS
variable "allocated_storage" {
  description = "RDS allocated storage"
  type        = number
  default     = 10
}

variable "max_allocated_storage" {
  description = "RDS max allocated storage"
  type        = number
  default     = 50
}

variable "storage_type" {
  description = "RDS storage type"
  type        = string
  default     = "gp2"
}

variable "storage_encrypted" {
  description = "RDS storage encrypted"
  type        = bool
  default     = false
}

// authentication for RDS
variable "db_username" {
  description = "RDS username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}

// multi AZ for RDS
variable "multi_az" {
  description = "RDS multi AZ"
  type        = bool
  default     = false
}

// backup window for RDS
variable "backup_window" {
  description = "RDS backup window"
  type        = string
  default     = "04:00-05:00"
}

variable "backup_retention_period" {
  description = "RDS backup retention period"
  type        = number
  default     = 7
}


// maintenance for RDS
variable "maintenance_window" {
  description = "RDS maintenance window"
  type        = string
  default     = "Mon:05:00-Mon:06:00"
}

variable "auto_minor_version_upgrade" {
  description = "RDS auto minor version upgrade"
  type        = bool
  default     = true
}

// deletion protection for RDS
variable "deletion_protection" {
  description = "RDS deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "RDS skip final snapshot"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "RDS apply immediately"
  type        = bool
  default     = true
}
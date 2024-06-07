variable "deploy_odaa_infra" {
  type        = bool
  description = "Deploy the ODAA infrastructure"
  default     = true
}

variable "deploy_odaa_cluster" {
  type        = bool
  description = "Deploy the ODAA Cluster"
  default     = true
}

variable "odaa_infra_name" {
  description = "The name of the resource"
  type        = string
  default     = "odaa-infra"
}
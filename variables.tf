variable "node_count" {
  description = "Number of nodes for the AKS cluster"
  type        = number
  default     = 1  
}

variable "environment" {
  description = "The environment for the deployment"
  type        = string
  default     = "dev"
}

variable "db-sku" {
  description = "The SKU for the database"
  type        = string
  default     = "Basic"
}
variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  description = "location"
  type        = string
  default     = "West US 2"
}

locals {
  akv_name = join("",[var.project,var.environment,"akv"])
  acr_name = join("",[var.project,var.environment,"acr"])  
}

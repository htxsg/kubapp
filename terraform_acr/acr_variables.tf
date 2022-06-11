
# Assume project, environemnt and region variables already defined

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
  acr_name = join("a",[var.project,var.environment,"acr"])
}

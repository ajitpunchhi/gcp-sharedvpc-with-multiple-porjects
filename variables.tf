# Variables
variable "host_project_id" {
  description = "The ID of the host project for Shared VPC"
  type        = string
}

variable "prod_service_project_id" {
  description = "The ID of the production service project"
  type        = string
}

variable "dev_service_project_id" {
  description = "The ID of the development service project"
  type        = string
}

variable "organization_id" {
  description = "The organization ID"
  type        = string
}

variable "billing_account" {
  description = "The billing account ID"
  type        = string
}

variable "default_region" {
  description = "Default region for resources"
  type        = string

}

variable "secondary_region" {
  description = "Secondary region for resources"
  type        = string
}
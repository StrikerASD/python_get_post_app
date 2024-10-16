variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "regions" {
  description = "GCP Regions"
  type        = set(string)
  default     = ["europe-west3", "europe-west4"]
}

variable "default_region" {
  description = "Default GCP region for Terraform resources."
  type        = string
  default     = "europe-west3"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "repo_name" {
  description = "Artifact Registry repository name"
  type        = string
}

variable "container_image" {
  description = "Container image URL."
  type        = string
}

variable "image_name" {
  description = "Docker image name"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}
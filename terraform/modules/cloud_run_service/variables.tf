variable "name" {
  description = "Name of the Cloud Run service."
  type        = string
}

variable "region" {
  description = "GCP region to deploy the service."
  type        = string
}

variable "image" {
  description = "Container image to deploy."
  type        = string
}

output "cloud_run_service_url" {
  description = "The URL of the deployed Cloud Run service."
  value       = google_cloud_run_service.default.status[0].url
}

output "region" {
  description = "The region where the Cloud Run service is deployed."
  value       = google_cloud_run_service.default.location
}

output "service_name" {
  description = "The name of the Cloud Run service."
  value       = google_cloud_run_service.default.name
}
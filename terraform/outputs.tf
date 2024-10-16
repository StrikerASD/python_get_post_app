output "google_compute_backend_service" {
  value = { for k, v in google_compute_backend_service.regional_backend : k => v.name }
}

output "load_balancer_ip" {
  description = "The IP address of the global load balancer."
  value       = google_compute_global_address.default.name
}

output "load_balancer_url" {
  description = "The URL of the global load balancer."
  value       = "http://${google_compute_global_address.default.address}"
}

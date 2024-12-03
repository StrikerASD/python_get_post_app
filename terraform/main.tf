provider "google" {
  project = var.project_id
  region  = var.default_region
}

resource "google_compute_health_check" "default" {
  name                = "${var.service_name}-hc"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

module "cloud_run_services" {
  source   = "./modules/cloud_run_service"
  for_each = toset(var.regions)

  name   = "${var.service_name}-${each.key}"
  region = each.key
  image  = var.container_image
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  for_each = module.cloud_run_services

  name                  = "${var.service_name}-neg-${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = "europe-west3"

  cloud_run {
    service = each.value.service_name
  }
}

resource "google_compute_backend_service" "regional_backend" {
  for_each              = toset(var.regions)
  name                  = "${var.service_name}-backend-${each.key}"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg[each.key].id
    # Removed health_checks line since Serverless NEGs do not require them
  }
}

resource "google_compute_url_map" "default" {
  name            = "${var.service_name}-url-map"
  default_service = google_compute_backend_service.regional_backend["europe-west3"].self_link
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.service_name}-http-proxy"
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_global_address" "default" {
  name = "${var.service_name}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "default" {
  name        = "${var.service_name}-forwarding-rule"
  ip_address  = google_compute_global_address.default.address
  ip_protocol = "TCP"
  port_range  = "80"
  target      = google_compute_target_http_proxy.default.self_link
}



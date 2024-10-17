provider "google" {
  project = var.project_id
  region  = var.default_region
}

resource "google_compute_health_check" "default" {
  name               = "${var.service_name}-hc"
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
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

resource "google_compute_region_network_endpoint_group" "serverless_neg-ew3" {
  name                  = "europe-west3-neg"
  network_endpoint_type = "SERVERLESS"
  region = "europe-west3"
  depends_on = [module.cloud_run_services]

  cloud_run {
    service = module.cloud_run_services["europe-west3"].service_name
  }
}

resource "google_compute_region_network_endpoint_group" "serverless_neg-ew4" {
  name                  = "europe-west4-neg"
  network_endpoint_type = "SERVERLESS"
  region = "europe-west4"
  depends_on = [module.cloud_run_services]

  cloud_run {
    service = module.cloud_run_services["europe-west4"].service_name
  }
}

resource "google_compute_backend_service" "regional-backend-global" {
  name                  = "${var.service_name}-backend-global"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "HTTP"

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg-ew3.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg-ew4.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 0.0
  }
}

resource "google_compute_url_map" "default" {
  name            = "${var.service_name}-url-map"
  default_service = google_compute_backend_service.regional-backend-global.self_link
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



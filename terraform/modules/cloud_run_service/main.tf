resource "google_cloud_run_service" "default" {
  name     = var.name
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" : "1"
        "autoscaling.knative.dev/maxScale" : "1"
        "run.googleapis.com/cpu-throttling" : "false"
      }
    }
    spec {
      containers {
        image = var.image

        # Add environment variables (if any)
        # env {
        #   name  = "ENV_VAR_NAME"
        #   value = "value"
        # }

        # Ports (if needed)
        # ports {
        #   container_port = 8080
        # }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true
}

resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers" # Change to specific members for restricted access
}

locals {
  address = var.create_address ? join("", google_compute_global_address.default[*].address) : var.address


  is_internal = var.load_balancing_scheme == "INTERNAL_SELF_MANAGED"

  # Create a map with hosts as keys and empty lists as initial values
  hosts = toset([for service in var.backend_services : service.host])
  backend_services_by_host = {
    for host in local.hosts : 
    host => [
      for s in var.backend_services : 
      s if s.host == host
    ]
  }
}

### IPv4 block ###
resource "google_compute_global_forwarding_rule" "http" {
  provider              = google-beta
  project               = var.project_id
  name                  = var.name
  target                = google_compute_target_http_proxy.default.self_link
  ip_address            = local.address
  port_range            = var.http_port
  labels                = var.labels
  load_balancing_scheme = var.load_balancing_scheme
}

resource "google_compute_global_address" "default" {
  provider   = google-beta
  count      = local.is_internal ? 0 : var.create_address ? 1 : 0
  project    = var.project_id
  name       = "${var.name}-address"
  ip_version = "IPV4"
  labels     = var.labels
}
### IPv4 block ###

# HTTP proxy when http forwarding is true
resource "google_compute_target_http_proxy" "default" {
  project = var.project_id
  name    = "${var.name}-http-proxy"
  url_map = google_compute_url_map.default.self_link
}

resource "google_compute_url_map" "default" {
  provider        = google-beta
  project         = var.project_id
  name            = "${var.name}-url-map"
  default_service = local.backend_services_by_host["*"][0].backend


  dynamic "host_rule" {
    for_each = local.backend_services_by_host
    content {
      hosts        = [host_rule.key]
      path_matcher = host_rule.key == "*" ? "default" : replace(host_rule.key, ".", "")
    }
  }

  dynamic "path_matcher" {
    for_each = local.backend_services_by_host
    content {
      name            = path_matcher.key == "*" ? "default" : replace(path_matcher.key, ".", "")
      default_service = path_matcher.value[0].backend

      dynamic "path_rule" {
        for_each = path_matcher.value
        content {
          paths = [ path_rule.value.path ]
          service = path_rule.value.backend
        }
      }
    }
  }
}

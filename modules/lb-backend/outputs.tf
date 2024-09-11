output "backend_service_info" {
  value = [{ host : var.domain_host, path : var.path, backend : google_compute_backend_service.default.self_link }]
}
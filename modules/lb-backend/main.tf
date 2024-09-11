resource "google_compute_backend_service" "default" {
  provider = google-beta

  project = coalesce(var.backend["project"], var.project_id)
  name    = var.name

  load_balancing_scheme = var.load_balancing_scheme

  port_name = lookup(var.backend, "port_name", "http")
  protocol  = lookup(var.backend, "protocol", "HTTP")

  description                     = lookup(var.backend, "description", null)
  connection_draining_timeout_sec = lookup(var.backend, "connection_draining_timeout_sec", null)
  enable_cdn                      = lookup(var.backend, "enable_cdn", false)
  compression_mode                = lookup(var.backend, "compression_mode", "DISABLED")
  custom_request_headers          = lookup(var.backend, "custom_request_headers", [])
  custom_response_headers         = lookup(var.backend, "custom_response_headers", [])
  session_affinity                = lookup(var.backend, "session_affinity", null)
  affinity_cookie_ttl_sec         = lookup(var.backend, "affinity_cookie_ttl_sec", null)
  locality_lb_policy              = lookup(var.backend, "locality_lb_policy", null)


  # To achieve a null backend edge_security_policy, set var.backend.edge_security_policy to "" (empty string), otherwise, it fallsback to var.edge_security_policy.
  edge_security_policy = var.backend["edge_security_policy"] == "" ? null : (var.backend["edge_security_policy"] == null ? var.edge_security_policy : var.backend.edge_security_policy)

  # To achieve a null backend security_policy, set var.backend.security_policy to "" (empty string), otherwise, it fallsback to var.security_policy.
  security_policy = var.backend["security_policy"] == "" ? null : (var.backend["security_policy"] == null ? var.security_policy : var.backend.security_policy)

  dynamic "backend" {
    for_each = toset(var.backend["groups"])
    content {
      description = lookup(backend.value, "description", null)
      group       = backend.value["group"]

    }
  }

  dynamic "backend" {
    for_each = toset(var.backend["serverless_neg_backends"])
    content {
      group = google_compute_region_network_endpoint_group.serverless_negs["neg-${var.name}-${backend.value.region}"].id
    }
  }

  dynamic "log_config" {
    for_each = lookup(lookup(var.backend, "log_config", {}), "enable", true) ? [1] : []
    content {
      enable      = lookup(lookup(var.backend, "log_config", {}), "enable", true)
      sample_rate = lookup(lookup(var.backend, "log_config", {}), "sample_rate", "1.0")
    }
  }

  dynamic "iap" {
    for_each = lookup(lookup(var.backend, "iap_config", {}), "enable", false) ? [1] : []
    content {
      oauth2_client_id     = lookup(lookup(var.backend, "iap_config", {}), "oauth2_client_id", "")
      oauth2_client_secret = lookup(lookup(var.backend, "iap_config", {}), "oauth2_client_secret", "")
    }
  }

  dynamic "cdn_policy" {
    for_each = var.backend.enable_cdn ? [1] : []
    content {
      cache_mode                   = var.backend.cdn_policy.cache_mode
      signed_url_cache_max_age_sec = var.backend.cdn_policy.signed_url_cache_max_age_sec
      default_ttl                  = var.backend.cdn_policy.default_ttl
      max_ttl                      = var.backend.cdn_policy.max_ttl
      client_ttl                   = var.backend.cdn_policy.client_ttl
      negative_caching             = var.backend.cdn_policy.negative_caching
      serve_while_stale            = var.backend.cdn_policy.serve_while_stale

      dynamic "negative_caching_policy" {
        for_each = var.backend.cdn_policy.negative_caching_policy != null ? [1] : []
        content {
          code = var.backend.cdn_policy.negative_caching_policy.code
          ttl  = var.backend.cdn_policy.negative_caching_policy.ttl
        }
      }

      dynamic "cache_key_policy" {
        for_each = var.backend.cdn_policy.cache_key_policy != null ? [1] : []
        content {
          include_host           = var.backend.cdn_policy.cache_key_policy.include_host
          include_protocol       = var.backend.cdn_policy.cache_key_policy.include_protocol
          include_query_string   = var.backend.cdn_policy.cache_key_policy.include_query_string
          query_string_blacklist = var.backend.cdn_policy.cache_key_policy.query_string_blacklist
          query_string_whitelist = var.backend.cdn_policy.cache_key_policy.query_string_whitelist
          include_http_headers   = var.backend.cdn_policy.cache_key_policy.include_http_headers
          include_named_cookies  = var.backend.cdn_policy.cache_key_policy.include_named_cookies
        }
      }

      dynamic "bypass_cache_on_request_headers" {
        for_each = toset(var.backend.cdn_policy.bypass_cache_on_request_headers) != null ? var.backend.cdn_policy.bypass_cache_on_request_headers : []
        content {
          header_name = bypass_cache_on_request_headers.value
        }
      }
    }
  }

  dynamic "outlier_detection" {
    for_each = var.backend.outlier_detection != null && (var.load_balancing_scheme == "INTERNAL_SELF_MANAGED" || var.load_balancing_scheme == "EXTERNAL_MANAGED") ? [1] : []
    content {
      consecutive_errors                    = var.backend.outlier_detection.consecutive_errors
      consecutive_gateway_failure           = var.backend.outlier_detection.consecutive_gateway_failure
      enforcing_consecutive_errors          = var.backend.outlier_detection.enforcing_consecutive_errors
      enforcing_consecutive_gateway_failure = var.backend.outlier_detection.enforcing_consecutive_gateway_failure
      enforcing_success_rate                = var.backend.outlier_detection.enforcing_success_rate
      max_ejection_percent                  = var.backend.outlier_detection.max_ejection_percent
      success_rate_minimum_hosts            = var.backend.outlier_detection.success_rate_minimum_hosts
      success_rate_request_volume           = var.backend.outlier_detection.success_rate_request_volume
      success_rate_stdev_factor             = var.backend.outlier_detection.success_rate_stdev_factor

      dynamic "base_ejection_time" {
        for_each = var.backend.outlier_detection.base_ejection_time != null ? [1] : []
        content {
          seconds = var.backend.outlier_detection.base_ejection_time.seconds
          nanos   = var.backend.outlier_detection.base_ejection_time.nanos
        }
      }

      dynamic "interval" {
        for_each = var.backend.outlier_detection.interval != null ? [1] : []
        content {
          seconds = var.backend.outlier_detection.interval.seconds
          nanos   = var.backend.outlier_detection.interval.nanos
        }
      }
    }
  }


}

resource "google_compute_region_network_endpoint_group" "serverless_negs" {
  for_each = { for serverless_neg_backend in var.backend.serverless_neg_backends : 
    "neg-${var.name}-${serverless_neg_backend.region}" => serverless_neg_backend }


  provider              = google-beta
  project               = var.project_id
  name                  = each.key
  network_endpoint_type = "SERVERLESS"
  region                = each.value.region

  dynamic "cloud_run" {
    for_each = each.value.type == "cloud-run" ? [1] : []
    content {
      service = each.value.service.name
    }
  }

  dynamic "cloud_function" {
    for_each = each.value.type == "cloud-function" ? [1] : []
    content {
      function = each.value.service.name
    }
  }

  dynamic "app_engine" {
    for_each = each.value.type == "app-engine" ? [1] : []
    content {
      service = each.value.service.name
      version = each.value.service.version
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
variable "name" {
  type = string
}

variable "load_balancing_scheme" {
  type    = string
  default = "EXTERNAL_MANAGED"
}

variable "project_id" {
  type = string
}

variable "backend" {
  type = object({
    project                 = optional(string)
    protocol                = optional(string)
    port_name               = optional(string)
    description             = optional(string)
    enable_cdn              = optional(bool)
    compression_mode        = optional(string)
    security_policy         = optional(string, null)
    edge_security_policy    = optional(string, null)
    custom_request_headers  = optional(list(string))
    custom_response_headers = optional(list(string))

    connection_draining_timeout_sec = optional(number)
    session_affinity                = optional(string)
    affinity_cookie_ttl_sec         = optional(number)
    locality_lb_policy              = optional(string)


    log_config = object({
      enable      = optional(bool)
      sample_rate = optional(number)
    })

    groups = list(object({
      group       = string
      description = optional(string)

    }))

    // serverless_neg_backends is mutually exclusive to groups.There can only be one serverless neg per region
    // with one of cloud-run, cloud-functions and app-engine as service.
    serverless_neg_backends = optional(list(object({
      region  = string,
      type    = string, // cloud-run, cloud-function and app-engine
      service = object({ name : string, version : optional(string) })
    })), [])

    iap_config = object({
      enable               = bool
      oauth2_client_id     = optional(string)
      oauth2_client_secret = optional(string)
    })
    cdn_policy = optional(object({
      cache_mode                   = optional(string)
      signed_url_cache_max_age_sec = optional(string)
      default_ttl                  = optional(number)
      max_ttl                      = optional(number)
      client_ttl                   = optional(number)
      negative_caching             = optional(bool)
      negative_caching_policy = optional(object({
        code = optional(number)
        ttl  = optional(number)
      }))
      serve_while_stale = optional(number)
      cache_key_policy = optional(object({
        include_host           = optional(bool)
        include_protocol       = optional(bool)
        include_query_string   = optional(bool)
        query_string_blacklist = optional(list(string))
        query_string_whitelist = optional(list(string))
        include_http_headers   = optional(list(string))
        include_named_cookies  = optional(list(string))
      }))
      bypass_cache_on_request_headers = optional(list(string))
    }))
    outlier_detection = optional(object({
      base_ejection_time = optional(object({
        seconds = number
        nanos   = optional(number)
      }))
      consecutive_errors                    = optional(number)
      consecutive_gateway_failure           = optional(number)
      enforcing_consecutive_errors          = optional(number)
      enforcing_consecutive_gateway_failure = optional(number)
      enforcing_success_rate                = optional(number)
      interval = optional(object({
        seconds = number
        nanos   = optional(number)
      }))
      max_ejection_percent        = optional(number)
      success_rate_minimum_hosts  = optional(number)
      success_rate_request_volume = optional(number)
      success_rate_stdev_factor   = optional(number)
    }))
  })
}

variable "edge_security_policy" {
  description = "The resource URL for the edge security policy to associate with the backend service"
  type        = string
  default     = null
}

variable "security_policy" {
  description = "The resource URL for the security policy to associate with the backend service"
  type        = string
  default     = null
}

variable "domain_host" {
  type = string
}

variable "path" {
  type = string
}
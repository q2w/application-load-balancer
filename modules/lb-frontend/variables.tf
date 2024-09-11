variable "project_id" {
  type = string
}

variable "name" {
  type = string
}

variable "http_port" {
  type    = number
  default = 80
}

variable "load_balancing_scheme" {
  type    = string
  default = "EXTERNAL_MANAGED"
}

variable "create_address" {
  type    = bool
  default = true
}

variable "address" {
  type    = string
  default = null
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "backend_services" {
  type = list(object({
    host : string
    path : string
    backend : string
  }))
}
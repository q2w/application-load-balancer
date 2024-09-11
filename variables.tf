variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "user_service_service_name" {
  type = string
}

variable "user_service_members" {
  type = list(string)
}

variable "user_service_containers" {
  type = list(object({ container_image : string, ports : object({ container_port : number }) }))
}

variable "user_service_vpc_access" {
  type = object({
    connector = optional(string)
    egress    = optional(string)
    network_interfaces = optional(object({
      network    = optional(string)
      subnetwork = optional(string)
      tags       = optional(list(string))
    }))
  })
}

variable "user_service_template_scaling" {
  type = object({ max_instance_count : number })
}

variable "user_service_service_account_project_roles" {
  type    = list(string)
  default = []
}

variable "catalog_service_service_name" {
  type = string
}

variable "catalog_service_members" {
  type = list(string)
}

variable "catalog_service_containers" {
  type = list(object({ container_image : string, ports : object({ container_port : number }) }))
}

variable "catalog_service_vpc_access" {
  type = object({
    connector = optional(string)
    egress    = optional(string)
    network_interfaces = optional(object({
      network    = optional(string)
      subnetwork = optional(string)
      tags       = optional(list(string))
    }))
  })
}

variable "catalog_service_template_scaling" {
  type = object({ max_instance_count : number })
}

variable "catalog_service_service_account_project_roles" {
  type    = list(string)
  default = []
}
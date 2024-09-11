module "user_service" {
  source                        = "github.com/q2w/terraform-google-cloud-run//modules/v2?ref=feat%2Fsa-in-cr-v2"
  project_id                    = var.project_id
  location                      = var.region
  service_name                  = var.user_service_service_name
  members                       = var.user_service_members
  containers                    = var.user_service_containers
  vpc_access                    = var.user_service_vpc_access
  template_scaling              = var.user_service_template_scaling
  service_account_project_roles = var.user_service_service_account_project_roles
}

module "catalog_service" {
  source                        = "github.com/q2w/terraform-google-cloud-run//modules/v2?ref=feat%2Fsa-in-cr-v2"
  project_id                    = var.project_id
  location                      = var.region
  service_name                  = var.catalog_service_service_name
  members                       = var.catalog_service_members
  containers                    = var.catalog_service_containers
  vpc_access                    = var.catalog_service_vpc_access
  template_scaling              = var.catalog_service_template_scaling
  service_account_project_roles = var.catalog_service_service_account_project_roles
}

module "lb_backend_user" {
  source      = "./modules/lb-backend"
  project_id  = var.project_id
  domain_host = "*"
  path        = "/users"
  name        = "lb-backend-user"
  backend = {
    groups                  = []
    serverless_neg_backends = [{ region : "us-central1", type : "cloud-run", service : { name : module.user_service.service_name } }]
    enable_cdn              = false

    iap_config = {
      enable = false
    }
    log_config = {
      enable = false
    }
  }
}

module "lb_backend_catalog" {
  source      = "./modules/lb-backend"
  project_id  = var.project_id
  domain_host = "*"
  path        = "/catalog"
  name        = "lb-backend-catalog"
  backend = {
    groups                  = []
    serverless_neg_backends = [{ region : "us-central1", type : "cloud-run", service : { name : module.catalog_service.service_name } }]
    enable_cdn              = false

    iap_config = {
      enable = false
    }
    log_config = {
      enable = false
    }
  }
}

module "lb_frontend" {
  source           = "./modules/lb-frontend"
  project_id       = var.project_id
  name             = "lb-frontend"
  backend_services = concat(module.lb_backend_user.backend_service_info, module.lb_backend_catalog.backend_service_info)
}
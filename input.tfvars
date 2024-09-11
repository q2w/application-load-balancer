project_id = "abhiwa-test-30112023"
region     = "us-central1"

user_service_service_name     = "user-service"
user_service_members          = ["allUsers"]
user_service_template_scaling = { max_instance_count : 4 }
user_service_containers = [
  {
    container_image : "gcr.io/cloudrun/hello"
    ports : { container_port : 80 }
  }
]
user_service_vpc_access = { network_interfaces : { network : "default", subnetwork : "default" } }


catalog_service_service_name     = "catalog-service"
catalog_service_members          = ["allUsers"]
catalog_service_template_scaling = { max_instance_count : 4 }
catalog_service_containers = [
  {
    container_image : "gcr.io/cloudrun/hello"
    ports : { container_port : 80 }
  }
]
catalog_service_vpc_access = { network_interfaces : { network : "default", subnetwork : "default" } }


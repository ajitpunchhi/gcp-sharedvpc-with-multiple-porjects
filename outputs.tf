# Outputs
output "host_project_id" {
  description = "The ID of the host project"
  value       = google_project.host_project.project_id
}

output "prod_service_project_id" {
  description = "The ID of the production service project"
  value       = google_project.prod_service_project.project_id
}

output "dev_service_project_id" {
  description = "The ID of the development service project"
  value       = google_project.dev_service_project.project_id
}

output "shared_vpc_network_id" {
  description = "The ID of the shared VPC network"
  value       = google_compute_network.shared_vpc.id
}

output "prod_subnets" {
  description = "Production subnet details"
  value = {
    prod_subnet_01 = {
      name          = google_compute_subnetwork.prod_subnet_01.name
      ip_cidr_range = google_compute_subnetwork.prod_subnet_01.ip_cidr_range
      region        = google_compute_subnetwork.prod_subnet_01.region
    }
    prod_subnet_02 = {
      name          = google_compute_subnetwork.prod_subnet_02.name
      ip_cidr_range = google_compute_subnetwork.prod_subnet_02.ip_cidr_range
      region        = google_compute_subnetwork.prod_subnet_02.region
    }
  }
}

output "dev_subnets" {
  description = "Development subnet details"
  value = {
    dev_subnet_01 = {
      name          = google_compute_subnetwork.dev_subnet_01.name
      ip_cidr_range = google_compute_subnetwork.dev_subnet_01.ip_cidr_range
      region        = google_compute_subnetwork.dev_subnet_01.region
    }
    dev_subnet_02 = {
      name          = google_compute_subnetwork.dev_subnet_02.name
      ip_cidr_range = google_compute_subnetwork.dev_subnet_02.ip_cidr_range
      region        = google_compute_subnetwork.dev_subnet_02.region
    }
  }
}

output "interconnect_attachments" {
  description = "Cloud Interconnect attachment details"
  value = {
    region_1 = {
      attachment_1 = google_compute_interconnect_attachment.region_1_attachment_1.cloud_router_ip_address
      attachment_2 = google_compute_interconnect_attachment.region_1_attachment_2.cloud_router_ip_address
    }
    region_12 = {
      attachment_1 = google_compute_interconnect_attachment.region_12_attachment_1.cloud_router_ip_address
      attachment_2 = google_compute_interconnect_attachment.region_12_attachment_2.cloud_router_ip_address
    }
  }
}
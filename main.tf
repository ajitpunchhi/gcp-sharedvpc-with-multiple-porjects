# Host Project
resource "google_project" "host_project" {
  name            = "Shared VPC Host Project"
  project_id      = var.host_project_id
  org_id          = var.organization_id
  billing_account = var.billing_account
}

# Service Projects
resource "google_project" "prod_service_project" {
  name            = "Production Service Project"
  project_id      = var.prod_service_project_id
  org_id          = var.organization_id
  billing_account = var.billing_account
}

resource "google_project" "dev_service_project" {
  name            = "Development Service Project"
  project_id      = var.dev_service_project_id
  org_id          = var.organization_id
  billing_account = var.billing_account
}

# Enable required APIs for host project
resource "google_project_service" "host_project_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  
  project = google_project.host_project.project_id
  service = each.value
  
  disable_dependent_services = true
}

# Enable required APIs for service projects
resource "google_project_service" "prod_service_project_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com"
  ])
  
  project = google_project.prod_service_project.project_id
  service = each.value
  
  disable_dependent_services = true
}

resource "google_project_service" "dev_service_project_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com"
  ])
  
  project = google_project.dev_service_project.project_id
  service = each.value
  
  disable_dependent_services = true
}

# Enable Shared VPC on host project
resource "google_compute_shared_vpc_host_project" "host" {
  project = google_project.host_project.project_id
  
  depends_on = [google_project_service.host_project_apis]
}

# Attach service projects to Shared VPC
resource "google_compute_shared_vpc_service_project" "prod_service" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = google_project.prod_service_project.project_id
  
  depends_on = [google_project_service.prod_service_project_apis]
}

resource "google_compute_shared_vpc_service_project" "dev_service" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = google_project.dev_service_project.project_id
  
  depends_on = [google_project_service.dev_service_project_apis]
}

# Create VPC Network in host project
resource "google_compute_network" "shared_vpc" {
  name                    = "shared-vpc-network"
  project                 = google_compute_shared_vpc_host_project.host.project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  
  depends_on = [google_compute_shared_vpc_host_project.host]
}

# Production Subnets
resource "google_compute_subnetwork" "prod_subnet_01" {
  name          = "prod-subnet-01"
  project       = google_compute_shared_vpc_host_project.host.project
  region        = var.default_region
  network       = google_compute_network.shared_vpc.id
  ip_cidr_range = "10.1.0.0/24"
  
  secondary_ip_range {
    range_name    = "prod-pods-01"
    ip_cidr_range = "10.10.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "prod-services-01"
    ip_cidr_range = "10.20.0.0/16"
  }
}

resource "google_compute_subnetwork" "prod_subnet_02" {
  name          = "prod-subnet-02"
  project       = google_compute_shared_vpc_host_project.host.project
  region        = var.secondary_region
  network       = google_compute_network.shared_vpc.id
  ip_cidr_range = "10.2.0.0/24"
  
  secondary_ip_range {
    range_name    = "prod-pods-02"
    ip_cidr_range = "10.11.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "prod-services-02"
    ip_cidr_range = "10.21.0.0/16"
  }
}

# Development Subnets
resource "google_compute_subnetwork" "dev_subnet_01" {
  name          = "dev-subnet-01"
  project       = google_compute_shared_vpc_host_project.host.project
  region        = var.default_region
  network       = google_compute_network.shared_vpc.id
  ip_cidr_range = "10.3.0.0/24"
  
  secondary_ip_range {
    range_name    = "dev-pods-01"
    ip_cidr_range = "10.30.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "dev-services-01"
    ip_cidr_range = "10.40.0.0/16"
  }
}

resource "google_compute_subnetwork" "dev_subnet_02" {
  name          = "dev-subnet-02"
  project       = google_compute_shared_vpc_host_project.host.project
  region        = var.secondary_region
  network       = google_compute_network.shared_vpc.id
  ip_cidr_range = "10.4.0.0/24"
  
  secondary_ip_range {
    range_name    = "dev-pods-02"
    ip_cidr_range = "10.31.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "dev-services-02"
    ip_cidr_range = "10.41.0.0/16"
  }
}

# Cloud Interconnect Attachments (VLAN attachments)
resource "google_compute_interconnect_attachment" "region_1_attachment_1" {
  name                     = "region-1-attachment-1"
  project                  = google_compute_shared_vpc_host_project.host.project
  region                   = var.default_region
  router                   = google_compute_router.region_1_router.id
  type                     = "PARTNER"
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  bandwidth                = "BPS_1G"
  vlan_tag8021q           = 100
}

resource "google_compute_interconnect_attachment" "region_1_attachment_2" {
  name                     = "region-1-attachment-2"
  project                  = google_compute_shared_vpc_host_project.host.project
  region                   = var.default_region
  router                   = google_compute_router.region_1_router.id
  type                     = "PARTNER"
  edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  bandwidth                = "BPS_1G"
  vlan_tag8021q           = 101
}

resource "google_compute_interconnect_attachment" "region_12_attachment_1" {
  name                     = "region-12-attachment-1"
  project                  = google_compute_shared_vpc_host_project.host.project
  region                   = var.secondary_region
  router                   = google_compute_router.region_12_router.id
  type                     = "PARTNER"
  edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  bandwidth                = "BPS_1G"
  vlan_tag8021q           = 200
}

resource "google_compute_interconnect_attachment" "region_12_attachment_2" {
  name                     = "region-12-attachment-2"
  project                  = google_compute_shared_vpc_host_project.host.project
  region                   = var.secondary_region
  router                   = google_compute_router.region_12_router.id
  type                     = "PARTNER"
  edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  bandwidth                = "BPS_1G"
  vlan_tag8021q           = 201
}

# Cloud Routers for Interconnect
resource "google_compute_router" "region_1_router" {
  name    = "region-1-router"
  project = google_compute_shared_vpc_host_project.host.project
  region  = var.default_region
  network = google_compute_network.shared_vpc.id
  
  bgp {
    asn = 65001
  }
}

resource "google_compute_router" "region_12_router" {
  name    = "region-12-router"
  project = google_compute_shared_vpc_host_project.host.project
  region  = var.secondary_region
  network = google_compute_network.shared_vpc.id
  
  bgp {
    asn = 65002
  }
}

# Firewall Rules
resource "google_compute_firewall" "allow_internal" {
  name      = "allow-internal"
  project   = google_compute_shared_vpc_host_project.host.project
  network   = google_compute_network.shared_vpc.name
  direction = "INGRESS"
  priority  = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "allow_ssh" {
  name      = "allow-ssh"
  project   = google_compute_shared_vpc_host_project.host.project
  network   = google_compute_network.shared_vpc.name
  direction = "INGRESS"
  priority  = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allowed"]
}

resource "google_compute_firewall" "allow_http_https" {
  name      = "allow-http-https"
  project   = google_compute_shared_vpc_host_project.host.project
  network   = google_compute_network.shared_vpc.name
  direction = "INGRESS"
  priority  = 1000
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}
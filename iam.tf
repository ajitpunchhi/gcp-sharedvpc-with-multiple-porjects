# IAM permissions for service projects to use Shared VPC subnets
resource "google_project_iam_member" "prod_compute_network_user" {
  project = google_compute_shared_vpc_host_project.host.project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_project.prod_service_project.number}@cloudservices.gserviceaccount.com"
}

resource "google_project_iam_member" "dev_compute_network_user" {
  project = google_compute_shared_vpc_host_project.host.project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_project.dev_service_project.number}@cloudservices.gserviceaccount.com"
}

# Subnet-level IAM for production service project
resource "google_compute_subnetwork_iam_member" "prod_subnet_01_user" {
  project    = google_compute_shared_vpc_host_project.host.project
  region     = var.default_region
  subnetwork = google_compute_subnetwork.prod_subnet_01.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_project.prod_service_project.number}@cloudservices.gserviceaccount.com"
}

resource "google_compute_subnetwork_iam_member" "prod_subnet_02_user" {
  project    = google_compute_shared_vpc_host_project.host.project
  region     = var.secondary_region
  subnetwork = google_compute_subnetwork.prod_subnet_02.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_project.prod_service_project.number}@cloudservices.gserviceaccount.com"
}

# Subnet-level IAM for development service project
resource "google_compute_subnetwork_iam_member" "dev_subnet_01_user" {
  project    = google_compute_shared_vpc_host_project.host.project
  region     = var.default_region
  subnetwork = google_compute_subnetwork.dev_subnet_01.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_project.dev_service_project.number}@cloudservices.gserviceaccount.com"
}

resource "google_compute_subnetwork_iam_member" "dev_subnet_02_user" {
  project    = google_compute_shared_vpc_host_project.host.project
  region     = var.secondary_region
  subnetwork = google_compute_subnetwork.dev_subnet_02.name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_project.dev_service_project.number}@cloudservices.gserviceaccount.com"
}

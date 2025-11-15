terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  
  request_timeout = "60s"
}

# Create VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = []
}

# Create Public Subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = var.public_subnet_name
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Create Private Subnet
resource "google_compute_subnetwork" "private_subnet" {
  name          = var.private_subnet_name
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Create Firewall Rule - Allow SSH (for management)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}

# Create Firewall Rule - Allow HTTP/HTTPS and Application Port
resource "google_compute_firewall" "allow_app" {
  name    = "allow-app-traffic"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443", var.app_port]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-app"]
}

# Create Service Account for Compute Engine instance
resource "google_service_account" "compute_sa" {
  account_id   = "flask-backend-sa"
  display_name = "Flask Backend Service Account"
}

# Grant Artifact Registry read permissions to service account
resource "google_project_iam_member" "artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.compute_sa.email}"
}

# Create Compute Engine Instance with Container
resource "google_compute_instance" "app_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.self_link

    access_config {
      # Ephemeral public IP
    }
  }

  tags = ["allow-ssh", "allow-app"]

  metadata = {
    enable-oslogin = "true"
  }

  service_account {
    email  = google_service_account.compute_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = templatefile("${path.module}/startup-script.sh", {
    container_image = var.container_image
    app_port        = var.app_port
    REGISTRY_HOST   = "${var.region}-docker.pkg.dev"
  })

  labels = {
    environment = "production"
    application = "flask-backend"
  }

  depends_on = [
    google_compute_firewall.allow_ssh,
    google_compute_firewall.allow_app
  ]
}

# Output values
output "instance_public_ip" {
  description = "Public IP of the Compute Engine instance"
  value       = google_compute_instance.app_instance.network_interface[0].access_config[0].nat_ip
}

output "instance_name" {
  description = "Name of the Compute Engine instance"
  value       = google_compute_instance.app_instance.name
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.vpc.name
}

output "public_subnet_name" {
  description = "Name of the public subnet"
  value       = google_compute_subnetwork.public_subnet.name
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.private_subnet.name
}

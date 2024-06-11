provider "google" {
  project     = "saravana95"
  region      = "us-central1"
}
locals {
  env = "desk"
}
terraform {
  backend "gcs" {
    bucket  = "saravana-desk-state-backup-bucket"
    prefix  = "terraform/state"
  }
}

resource "google_compute_subnetwork" "custom_subnet" {
  name          = "${local.env}-subnet-1"
  region        = "us-east1"  # Specify the same region as the VPC
  network       =  "projects/saravana95/global/networks/default-vpc"
  ip_cidr_range = "10.0.4.0/24"  # Specify the CIDR range for your subnets
}

resource "google_compute_firewall" "allow_firewall" {
  name    = "${local.env}-allow-8080"
  network =  "projects/saravana95/global/networks/default-vpc"
  direction = "INGRESS"
  priority = 1000
  
  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any source
  target_tags = ["desktop"]
}


# Create a Google Compute Engine instance
resource "google_compute_instance" "my_instance" {
  name         = "${local.env}"
  machine_type = "n2-standard-2"
  zone         = "us-east1-d"

  boot_disk {
    auto_delete = true

    initialize_params {
      image =  "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240519"      
      size = 20
      type = "pd-balanced"
    }
  }

network_interface {
    network =  "projects/saravana95/global/networks/default-vpc"
    subnetwork = google_compute_subnetwork.custom_subnet.self_link
 
    access_config {}
}

service_account {
    email  = "default"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

tags = ["desktop"]

metadata = {
  ssh-keys = "root:${file("/var/lib/jenkins/.ssh/id_rsa.pub")}"
}
}

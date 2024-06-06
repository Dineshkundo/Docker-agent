variable "project_id" {
description = "jenkins"
type = string
default = "saravana95"
}

variable "roles" {
  default = [
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/iam.serviceAccountUser",
    "roles/compute.instanceAdmin",
    "roles/storage.admin"
  ]
}

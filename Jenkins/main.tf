provider "google" {
  project     = "saravana95"
}

module "master" {
source = "/root/Jenkins/modules/master"
}

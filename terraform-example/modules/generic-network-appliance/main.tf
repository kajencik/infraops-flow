terraform {
  required_version = ">= 1.6.0"
}

resource "terraform_data" "network_appliance" {
  input = {
    name                   = var.name
    role                   = var.role
    provider_label         = var.provider_label
    region                 = var.region
    appliance_class        = var.appliance_class
    exposure_strategy      = var.exposure_strategy
    management_plane       = var.management_plane
    protected_cidr_labels  = var.protected_cidr_labels
    lifecycle_boundary     = var.lifecycle_boundary
    tags                   = var.tags
  }
}
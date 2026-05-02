terraform {
  required_version = ">= 1.6.0"
}

resource "terraform_data" "utility_node" {
  input = {
    name                = var.name
    role                = var.role
    provider_label      = var.provider_label
    region              = var.region
    instance_class      = var.instance_class
    image_label         = var.image_label
    private_address     = var.private_address
    public_exposure     = var.public_exposure
    bootstrap_template  = var.bootstrap_template
    tags                = var.tags
    lifecycle_boundary  = var.lifecycle_boundary
  }
}
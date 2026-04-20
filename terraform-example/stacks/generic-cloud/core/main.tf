locals {
  common_tags = {
    environment = var.environment_name
    provider    = var.provider_label
    lifecycle   = "core"
    managedBy   = "terraform-example"
  }
}

module "hub_node" {
  source = "../../../modules/generic-utility-node"

  name               = var.hub_node_name
  role               = "wireguard-hub"
  provider_label     = var.provider_label
  region             = var.region
  instance_class     = var.hub_instance_class
  image_label        = var.hub_image_label
  private_address    = var.hub_private_address
  public_exposure    = var.exposure_strategy
  bootstrap_template = "../../../templates/cloud-init-wireguard-node.yaml.tftpl"
  lifecycle_boundary = "core"
  tags               = local.common_tags
}

module "network_appliance" {
  source = "../../../modules/generic-network-appliance"

  name                  = var.network_appliance_name
  role                  = "network-appliance"
  provider_label        = var.provider_label
  region                = var.region
  appliance_class       = var.network_appliance_class
  exposure_strategy     = var.exposure_strategy
  management_plane      = var.management_plane
  protected_cidr_labels = var.protected_cidr_labels
  lifecycle_boundary    = "core"
  tags                  = local.common_tags
}
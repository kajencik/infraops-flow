locals {
  common_tags = {
    environment = var.environment_name
    provider    = var.provider_label
    lifecycle   = "spoke"
    managedBy   = "terraform-example"
  }
}

module "spoke_nodes" {
  source   = "../../../modules/generic-utility-node"
  for_each = var.spoke_nodes

  name               = each.key
  role               = each.value.role
  provider_label     = var.provider_label
  region             = var.region
  instance_class     = each.value.instance_class
  image_label        = each.value.image_label
  private_address    = each.value.private_address
  public_exposure    = each.value.public_exposure
  bootstrap_template = "../../../templates/cloud-init-wireguard-node.yaml.tftpl"
  lifecycle_boundary = "spoke"
  tags               = local.common_tags
}
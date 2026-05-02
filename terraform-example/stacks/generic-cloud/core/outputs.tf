output "core_assets" {
  description = "Provider-neutral asset summary for the long-lived cloud core."
  value = {
    hub_node          = module.hub_node.asset_model
    public_web_node   = module.public_web_node.asset_model
    network_appliance = module.network_appliance.asset_model
    cost_profile_name = var.cost_profile_name
  }
}
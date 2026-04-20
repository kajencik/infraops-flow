output "spoke_assets" {
  description = "Provider-neutral asset summary for disposable or test spoke nodes."
  value = {
    for name, module_ref in module.spoke_nodes :
    name => module_ref.asset_model
  }
}
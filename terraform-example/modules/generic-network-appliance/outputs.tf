output "asset_model" {
  description = "Provider-neutral representation of the network appliance role for notes, inventory, or validation summaries."
  value       = terraform_data.network_appliance.output
}
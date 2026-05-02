output "asset_model" {
  description = "Provider-neutral representation of the utility node for notes, inventory, or validation summaries."
  value       = terraform_data.utility_node.output
}
variable "provider_label" {
  type        = string
  description = "Generic provider label for notes and outputs."
}

variable "region" {
  type        = string
  description = "Generic region or location label."
}

variable "environment_name" {
  type        = string
  description = "Short environment label, for example public-lab or utility-core."
}

variable "hub_node_name" {
  type        = string
  description = "Logical name of the long-lived cloud utility node."
}

variable "hub_instance_class" {
  type        = string
  description = "Generic VM class label for the hub node."
}

variable "hub_image_label" {
  type        = string
  description = "Generic image label for the hub node bootstrap path."
}

variable "hub_private_address" {
  type        = string
  description = "Modeled private address of the hub node."
}

variable "network_appliance_name" {
  type        = string
  description = "Logical name of the generic network appliance role."
}

variable "network_appliance_class" {
  type        = string
  description = "Generic class or service tier for the network appliance role."
}

variable "exposure_strategy" {
  type        = string
  description = "How the core stack is publicly exposed."
}

variable "management_plane" {
  type        = string
  description = "How the network appliance is managed."
}

variable "protected_cidr_labels" {
  type        = list(string)
  description = "Named protected segments referenced by notes and checks."
  default     = []
}

variable "cost_profile_name" {
  type        = string
  description = "Name of the cost model profile associated with this stack."
}
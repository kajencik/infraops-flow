variable "name" {
  type        = string
  description = "Logical asset name for the utility node."
}

variable "role" {
  type        = string
  description = "Operational role, for example wireguard-hub or remote-admin-node."
}

variable "provider_label" {
  type        = string
  description = "Human-readable provider label used by the notes and outputs."
}

variable "region" {
  type        = string
  description = "Generic region or location label."
}

variable "instance_class" {
  type        = string
  description = "Generic VM or instance size label."
}

variable "image_label" {
  type        = string
  description = "Generic image label for the node bootstrap path."
}

variable "private_address" {
  type        = string
  description = "Private address used inside the modeled cloud network."
}

variable "public_exposure" {
  type        = string
  description = "How the node is exposed publicly, for example direct-ip or behind-appliance."
}

variable "bootstrap_template" {
  type        = string
  description = "Path to the bootstrap template used for initialization."
}

variable "tags" {
  type        = map(string)
  description = "Metadata tags that can be mirrored into inventory or notes."
  default     = {}
}

variable "lifecycle_boundary" {
  type        = string
  description = "Core or spoke-like lifecycle classification."
}
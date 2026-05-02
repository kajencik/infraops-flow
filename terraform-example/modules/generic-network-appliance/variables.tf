variable "name" {
  type        = string
  description = "Logical asset name for the network appliance role."
}

variable "role" {
  type        = string
  description = "Operational role, for example ingress-gateway or edge-policy-node."
}

variable "provider_label" {
  type        = string
  description = "Human-readable provider label used by notes and outputs."
}

variable "region" {
  type        = string
  description = "Generic region or location label."
}

variable "appliance_class" {
  type        = string
  description = "Generic sizing or service-class label for the appliance role."
}

variable "exposure_strategy" {
  type        = string
  description = "How the appliance handles exposure, for example direct-ingress or managed-edge-service."
}

variable "management_plane" {
  type        = string
  description = "How the appliance is managed operationally."
}

variable "protected_cidr_labels" {
  type        = list(string)
  description = "Named CIDR groups or protected segments described in notes and policy docs."
  default     = []
}

variable "lifecycle_boundary" {
  type        = string
  description = "Core or spoke-like lifecycle classification."
}

variable "tags" {
  type        = map(string)
  description = "Metadata tags that can be mirrored into inventory or notes."
  default     = {}
}
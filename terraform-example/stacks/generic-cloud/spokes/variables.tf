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
  description = "Short environment label for the disposable spoke set."
}

variable "spoke_nodes" {
  type = map(object({
    instance_class  = string
    image_label     = string
    private_address = string
    public_exposure = string
    role            = string
  }))
  description = "Disposable or test nodes that should be safe to recreate independently from the core stack."
}
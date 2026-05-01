variable "cluster_name" {
    description = "EKS Cluster Name"
    type = string
}

variable "subnet_ids" {
    description = "List of subnet IDs for the EKS cluster"
    type = list(string)
}
variable "node_groups" {
  description = "EKS Node group configuration"
  type=map(object({
    instance_types = list(string)
    capacity_type = string
    scaling_config = object({
      desired_size = number
      max_size = number
      min_size = number
    })
  }))
}
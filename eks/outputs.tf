output "cluster_enpoint" {
    value = aws_eks_cluster.main.endpoint
    description = "EKS Cluster Endpoint"
}
output "cluster_name" {
    value = aws_eks_cluster.main.name
    description = "EKS Cluster Name"
}
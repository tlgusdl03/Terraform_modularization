output "helm_release_name" {
  description = "The name of the Helm release"
  value       = helm_release.aws_load_balancer_controller.name
}

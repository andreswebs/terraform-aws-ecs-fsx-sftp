output "ecs_cluster" {
  value       = aws_ecs_cluster.this
  description = "The aws_ecs_cluster resource"
}

output "autoscaling_group" {
  value       = aws_autoscaling_group.this
  description = "The aws_autoscaling_group resource"
}

output "launch_template" {
  value       = aws_launch_template.this
  description = "The aws_launch_template resource"
}

output "ecs_task_definition" {
  value       = aws_ecs_task_definition.this
  description = "The aws_ecs_task_definition resource"
}

output "ecs_service" {
  value       = aws_ecs_service.this
  description = "The aws_ecs_service resource"
}

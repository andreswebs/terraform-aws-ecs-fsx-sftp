output "ecs_cluster" {
  value       = aws_ecs_cluster.this
  description = "The aws_ecs_cluster resource"
}

output "launch_template" {
  value       = aws_launch_template.this
  description = "The aws_launch_template resource"
}

output "task_definition" {
  value       = aws_ecs_task_definition.this
  description = "The aws_ecs_task_definition resource"
}

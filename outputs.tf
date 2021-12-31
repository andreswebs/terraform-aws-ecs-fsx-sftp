output "ecs_cluster" {
  value = aws_ecs_cluster.this
}

output "launch_template" {
  value = aws_launch_template.this
}

output "task_definition" {
  value = aws_ecs_task_definition.sftp
}

output "role" {
  description = "ECS roles"
  value = {
    ecs_task      = var.create_task_role ? aws_iam_role.ecs_task[0] : null
    ecs_execution = var.create_execution_role ? aws_iam_role.ecs_execution[0] : null
    ecs_instance = var.create_instance_role ? aws_iam_role.ecs_instance[0] : null
  }
}

output "instance_profile" {
  description = "ECS instance profile"
  value = var.create_instance_role ? aws_iam_instance_profile.ecs_instance[0] : null
}

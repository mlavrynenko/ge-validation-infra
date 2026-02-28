output "event_rule_name" {
  value = aws_cloudwatch_event_rule.this.name
}

output "event_role_arn" {
  value = aws_iam_role.eventbridge_role.arn
}

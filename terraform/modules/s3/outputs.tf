output "input_bucket_name" {
  value = aws_s3_bucket.input.bucket
}

output "input_bucket_arn" {
  value = aws_s3_bucket.input.arn
}

output "results_bucket_name" {
  value = aws_s3_bucket.results.bucket
}

output "results_bucket_arn" {
  value = aws_s3_bucket.results.arn
}

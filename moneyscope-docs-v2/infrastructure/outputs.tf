output "ecr_auth_repo" {
  value = aws_ecr_repository.auth.repository_url
}

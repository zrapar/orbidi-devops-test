output "live_url" {
  value = var.create ? "https://${local.domain_info.name}" : null
}
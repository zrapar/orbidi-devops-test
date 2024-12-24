# Retrieves the Cloudflare zone information for the specified domain
data "cloudflare_zone" "zone" {
  # Extracts the base domain (e.g., "example.com") from the full domain (e.g., "api.example.com")
  name = join(".", slice(split(".", local.domain_info.name), length(split(".", local.domain_info.name)) - 2, length(split(".", local.domain_info.name))))
}

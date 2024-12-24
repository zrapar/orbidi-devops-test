output "apis_urls" {
  value = {
    fastapi = module.fastapi.live_url
    django  = module.django.live_url
  }
}

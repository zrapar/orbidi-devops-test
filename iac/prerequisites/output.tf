# Output the module's result securely
output "keys" {
  value     = module.prerequisites # Exposes all outputs from the "prerequisites" module
  sensitive = true                 # Marks the output as sensitive to prevent it from being displayed in logs
}

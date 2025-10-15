output "registry_name" {
  value = digitalocean_container_registry.this.name
}

output "registry_url" {
  # You’ll push to: registry.digitalocean.com/<name>/<repo>:<tag>
  value = "registry.digitalocean.com/${digitalocean_container_registry.this.name}"
}

output "created_at" {
  value = digitalocean_container_registry.this.created_at
}

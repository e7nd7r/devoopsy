
output "droplet_id" {
  value       = digitalocean_droplet.this.id
  description = "Droplet ID"
}

output "droplet_name" {
  value       = digitalocean_droplet.this.name
  description = "Droplet name"
}

output "ipv4_address" {
  value       = digitalocean_droplet.this.ipv4_address
  description = "Public IPv4"
}

output "ipv6_address" {
  value       = digitalocean_droplet.this.ipv6_address
  description = "Primary IPv6 (if enabled)"
}

output "firewall_id" {
  value       = try(digitalocean_firewall.this[0].id, null)
  description = "Firewall ID (if created)"
}

output "volume_id" {
  value       = try(digitalocean_volume.this[0].id, null)
  description = "Volume ID (if created)"
}

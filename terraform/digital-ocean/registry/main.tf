terraform {
  required_version = ">= 1.6.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.42.0"
    }
  }
}

resource "digitalocean_container_registry" "this" {
  name                   = var.registry_name
  subscription_tier_slug = var.subscription_tier_slug
  # DigitalOcean registries are global; no region argument required
}


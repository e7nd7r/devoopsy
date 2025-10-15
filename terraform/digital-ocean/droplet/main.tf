terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.42.0"
    }
  }
}

resource "digitalocean_droplet" "this" {
  name   = var.name
  region = var.region
  size   = var.size
  image  = var.image

  ipv6       = var.ipv6
  monitoring = var.monitoring
  backups    = var.backups
  vpc_uuid   = var.vpc_uuid

  user_data = var.user_data

  ssh_keys = var.ssh_keys
  tags     = var.tags
}

# Optional volume
locals {
  volume_name_effective = coalesce(var.volume_name, "${var.name}-data")
}

resource "digitalocean_volume" "this" {
  count                   = var.volume_size_gb > 0 ? 1 : 0
  name                    = local.volume_name_effective
  region                  = var.region
  size                    = var.volume_size_gb
  initial_filesystem_type = var.volume_filesystem_type
  description             = "Data volume for ${var.name}"
  tags                    = var.tags
}

resource "digitalocean_volume_attachment" "this" {
  count      = var.volume_size_gb > 0 ? 1 : 0
  droplet_id = digitalocean_droplet.this.id
  volume_id  = digitalocean_volume.this[count.index].id
}

# Optional firewall
locals {
  base_inbound = concat(
    [
      {
        protocol         = "tcp"
        port_range       = "22"
        source_addresses = var.allow_ssh_from_cidrs
      }
    ],
    var.expose_http_https ? [
      { protocol = "tcp", port_range = "80", source_addresses = ["0.0.0.0/0", "::/0"] },
      { protocol = "tcp", port_range = "443", source_addresses = ["0.0.0.0/0", "::/0"] }
    ] : [],
    var.extra_inbound_rules
  )

  base_outbound = concat(
    [
      { protocol = "tcp", port_range = "all", destination_addresses = ["0.0.0.0/0", "::/0"] },
      { protocol = "udp", port_range = "all", destination_addresses = ["0.0.0.0/0", "::/0"] }
    ],
    var.extra_outbound_rules
  )
}

resource "digitalocean_firewall" "this" {
  count = var.with_firewall ? 1 : 0
  name  = "${var.name}-fw"

  droplet_ids = [digitalocean_droplet.this.id]

  dynamic "inbound_rule" {
    for_each = local.base_inbound
    content {
      protocol         = inbound_rule.value.protocol
      port_range       = inbound_rule.value.port_range
      source_addresses = inbound_rule.value.source_addresses
    }
  }

  dynamic "outbound_rule" {
    for_each = local.base_outbound
    content {
      protocol              = outbound_rule.value.protocol
      port_range            = outbound_rule.value.port_range
      destination_addresses = outbound_rule.value.destination_addresses
    }
  }

  tags = var.tags
}


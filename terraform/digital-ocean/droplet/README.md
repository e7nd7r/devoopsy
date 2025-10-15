# DigitalOcean Droplet Terraform Module

This Terraform module provisions a DigitalOcean Droplet with optional attached block storage (volume) and an optional firewall. It's designed to be a small, reusable component for deploying single Droplet instances with sensible defaults while offering flexibility through variables.

## Features

- Create a DigitalOcean Droplet with configurable name, region, size and image.
- Optionally enable IPv6, monitoring, and automated backups.
- Attach SSH keys to the Droplet.
- Optionally create and attach a block storage volume (if volume_size_gb > 0).
- Optionally create a firewall and attach it to the Droplet with configurable inbound/outbound rules.
- Exposes outputs for droplet ID, name, IPv4/IPv6 addresses, firewall ID (if created), and volume ID (if created).

## Resources Managed

- digitalocean_droplet.this
- digitalocean_volume.this (created when volume_size_gb > 0)
- digitalocean_volume_attachment.this (attached when volume_size_gb > 0)
- digitalocean_firewall.this (created when with_firewall = true)

## Inputs (variables)

- name (string, required)
  - Droplet name. DigitalOcean will slugify this.

- region (string, default: "sfo3")
  - DigitalOcean region slug (e.g., nyc3, sfo3, fra1)

- size (string, default: "s-1vcpu-1gb")
  - Droplet size slug (e.g., s-1vcpu-1gb, s-2vcpu-4gb)

- image (string, default: "ubuntu-22-04-x64")
  - Image slug or ID

- ssh_keys (list(string), default: [])
  - SSH key IDs or fingerprints to embed on the Droplet

- ipv6 (bool, default: true)
  - Enable IPv6 for the Droplet

- monitoring (bool, default: true)
  - Enable DigitalOcean monitoring

- backups (bool, default: false)
  - Enable DigitalOcean automated backups

- vpc_uuid (string, default: null)
  - Optional VPC UUID to place the Droplet into

- user_data (string, default: null, sensitive)
  - cloud-init user-data to provision the Droplet

- tags (list(string), default: [])
  - Tags applied to the Droplet

- with_firewall (bool, default: true)
  - Create a firewall and attach to this Droplet

- allow_ssh_from_cidrs (list(string), default: ["0.0.0.0/0", "::/0"])
  - CIDRs allowed to SSH when firewall is created

- expose_http_https (bool, default: true)
  - If true, include inbound rules for ports 80 and 443

- extra_inbound_rules (list(object), default: [])
  - Additional inbound firewall rules. Each rule: { protocol, port_range, source_addresses }

- extra_outbound_rules (list(object), default: [])
  - Additional outbound firewall rules. Each rule: { protocol, port_range, destination_addresses }

- volume_size_gb (number, default: 0)
  - If > 0, create and attach a block storage volume of this size (GB)

- volume_filesystem_type (string, default: "ext4")
  - Filesystem type hint for the volume

- volume_name (string, default: null)
  - Optional name for the volume (defaults to <name>-data)

## Outputs

- droplet_id
  - Droplet ID

- droplet_name
  - Droplet name

- ipv4_address
  - Public IPv4 address

- ipv6_address
  - Primary IPv6 address (if enabled)

- firewall_id
  - Firewall ID if a firewall was created, otherwise null

- volume_id
  - Volume ID if a block storage volume was created, otherwise null

## Usage Example

Simple example to create a Droplet with an attached volume and a firewall:

```hcl
module "web_droplet" {
  source = "./terraform/digital-ocean/droplet"

  name            = "web-01"
  region          = "nyc3"
  size            = "s-1vcpu-1gb"
  image           = "ubuntu-22-04-x64"
  ssh_keys        = ["your-ssh-key-id-or-fingerprint"]
  with_firewall   = true
  expose_http_https = true

  # create a 50GiB block volume and attach it
  volume_size_gb   = 50
  volume_filesystem_type = "ext4"

  tags = ["web", "production"]
}
```

More advanced example showing custom firewall rules and cloud-init:

```hcl
module "app" {
  source = "./terraform/digital-ocean/droplet"

  name   = "app-01"
  region = "fra1"
  size   = "s-2vcpu-2gb"
  image  = "ubuntu-22-04-x64"

  user_data = file("./cloud-init.yml")

  with_firewall = true
  allow_ssh_from_cidrs = ["203.0.113.0/24"]
  expose_http_https    = false
  extra_inbound_rules = [
    { protocol = "tcp", port_range = "8080", source_addresses = ["0.0.0.0/0"] }
  ]
}
```

## Notes & Considerations

- The module creates a firewall by default (with_firewall = true). If you manage firewalls centrally or via another module, set with_firewall = false and manage the droplet's access separately.
- The module uses try(...) on outputs that may not exist (firewall, volume) so outputs will be null when those resources are not created.
- The volume name defaults to "<name>-data" when volume_name is not provided.
- When creating volumes, DigitalOcean requires the volume and droplet to be in the same region.
- This module intentionally keeps cloud-init/user_data as a raw string to allow flexible user provisioning.

## License

This module is provided as-is without warranty. Use according to your organization's policies.


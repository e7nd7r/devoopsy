variable "name" {
  description = "Droplet name (will be slugified by DO)"
  type        = string
}

variable "region" {
  description = "DigitalOcean region slug (e.g., nyc3, sfo3, fra1)"
  type        = string
  default     = "sfo3"
}

variable "size" {
  description = "Droplet size slug (e.g., s-1vcpu-1gb, s-2vcpu-4gb)"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "image" {
  description = "Image slug or ID (e.g., ubuntu-22-04-x64)"
  type        = string
  default     = "ubuntu-22-04-x64"
}

variable "ssh_keys" {
  description = "List of SSH key IDs or fingerprints to embed on the Droplet"
  type        = list(string)
  default     = []
}

variable "ipv6" {
  description = "Enable IPv6"
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "Enable DO monitoring"
  type        = bool
  default     = true
}

variable "backups" {
  description = "Enable DO automated backups"
  type        = bool
  default     = false
}

variable "vpc_uuid" {
  description = "Optional VPC UUID to place the Droplet into"
  type        = string
  default     = null
}

variable "user_data" {
  description = "cloud-init user-data"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to the Droplet"
  type        = list(string)
  default     = []
}

variable "with_firewall" {
  description = "Create a firewall and attach to this Droplet"
  type        = bool
  default     = true
}

variable "allow_ssh_from_cidrs" {
  description = "CIDRs allowed to SSH (used when with_firewall = true)"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "expose_http_https" {
  description = "If true, allow inbound 80/443"
  type        = bool
  default     = true
}

variable "extra_inbound_rules" {
  description = <<EOT
Additional inbound firewall rules.
Each rule: { protocol, port_range, source_addresses }
protocol: tcp|udp|icmp, port_range: "all" or "start-end"
EOT
  type = list(object({
    protocol         = string
    port_range       = string
    source_addresses = list(string)
  }))
  default = []
}

variable "extra_outbound_rules" {
  description = "Additional outbound firewall rules (same schema but destination_addresses)"
  type = list(object({
    protocol              = string
    port_range            = string
    destination_addresses = list(string)
  }))
  default = []
}

variable "volume_size_gb" {
  description = "If > 0, create and attach a DO block storage volume of this size (GB)"
  type        = number
  default     = 0
}

variable "volume_filesystem_type" {
  description = "Filesystem type hint for the volume"
  type        = string
  default     = "ext4"
}

variable "volume_name" {
  description = "Name for the volume (defaults to <name>-data)"
  type        = string
  default     = null
}


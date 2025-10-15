variable "registry_name" {
  type        = string
  description = "Registry name (lowercase, letters/numbers/dashes)"
}

variable "subscription_tier_slug" {
  type        = string
  description = "Registry tier: basic or pro"
  default     = "basic"
}


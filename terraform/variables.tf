variable "neon_api_key" {
  description = "Neon API key (https://console.neon.tech/app/settings/api-keys)"
  type        = string
  sensitive   = true
}

variable "neon_region" {
  description = "Neon region"
  type        = string
  default     = "aws-ap-southeast-1"
}


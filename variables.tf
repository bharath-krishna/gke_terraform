variable "project_name" {
  type      = string
  sensitive = true
}

variable "service_account_id" {
  type      = string
  sensitive = true
}

variable "sa_display_name" {
  type      = string
  sensitive = true
}

variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "bharathk_in_hosted_zone_id" {
  type      = string
  sensitive = true
}

variable "profile_enabled" {
  type    = bool
  default = true
}

variable "tls_cert" {
  type      = string
  sensitive = true
}

variable "tls_key" {
  type      = string
  sensitive = true
}
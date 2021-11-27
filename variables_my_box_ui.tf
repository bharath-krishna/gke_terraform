variable "next_public_api_host" {
  type      = string
  sensitive = true
}

variable "firebase_client_email" {
  type      = string
  sensitive = true
}

variable "next_public_firebase_public_api_key" {
  type      = string
  sensitive = true
}

variable "next_public_firebase_auth_domain" {
  type      = string
  sensitive = true
}

variable "next_public_firebase_database_url" {
  type      = string
  sensitive = true
}

variable "next_public_firebase_project_id" {
  type      = string
  sensitive = true
}

variable "firebase_private_key" {
  type      = string
  sensitive = true
}

variable "cookie_secret_current" {
  type      = string
  sensitive = true
}

variable "cookie_secret_previous" {
  type      = string
  sensitive = true
}

variable "next_public_cookie_secure" {
  type      = bool
  sensitive = true
}

variable "next_public_firebase_app_name" {
  type      = string
  sensitive = true
}

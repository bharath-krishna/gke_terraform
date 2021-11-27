variable "api_firebase_configs" {
  type      = string
  sensitive = true
}


variable "box_api_origins" {
  type        = string
  description = "comma separated origins"
  sensitive   = true
}
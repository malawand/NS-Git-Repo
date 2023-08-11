variable "apic" {
  type = string
  default = "https://IP.OF.ACI.APIC"
}

variable "username" {
  type = string
  sensitive = true
}

variable "password" {
  type = string
  sensitive = true
}


variable "hostname" {
  default = "test"
  description = "domain name in libvirt, not hostname"
}

variable "domain" {
  default = "example.com"
}

variable "ip_type" {
  default = "dhcp"
}

variable "memoryMB" {
  default = 1024*1
}

variable "cpu" {
  default = 1
}

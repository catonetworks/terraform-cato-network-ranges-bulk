variable "site_id" {
  description = "Unique identifier of the site."
  type        = string
  default     = null
}

variable "interface_id" {
  description = "ID of the network interface to assign the network range to."
  type        = string
  default     = null
}

variable "interface_index" {
  description = "Index of the network interface to assign the network range to."
  type        = string
  default     = null
  validation {
    condition = var.interface_index == null || contains([
      "WAN1", "WAN2", "LAN", "LAN1", "LAN2", "LTE", "USB1", "USB2",
      "INT_1", "INT_2", "INT_3", "INT_4", "INT_5", "INT_6", "INT_7", "INT_8",
      "INT_9", "INT_10", "INT_11", "INT_12", "INT_13", "INT_14", "INT_15", "INT_16"
    ], var.interface_index)
    error_message = "interface_index must be one of: WAN1, WAN2, LAN, LAN1, LAN2, LTE, USB1, USB2, INT_1 to INT_16, or null."
  }
}

variable "name" {
  description = "Name of the network range."
  type        = string
}

variable "range_type" {
  description = "Type of the network range. Possible values: Direct, Native, Routed, SecondaryNative, VLAN."
  type        = string
  default     = null
  validation {
    condition     = contains(["Direct", "Native", "Routed", "SecondaryNative", "VLAN"], var.range_type)
    error_message = "range_type must be one of the following: Direct, Native, Routed, SecondaryNative, VLAN."
  }
}

variable "subnet" {
  description = "The subnet in CIDR notation."
  type        = string
  default     = null
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.subnet))
    error_message = "subnet must be a valid CIDR notation (e.g., 192.168.1.0/24)."
  }
}

variable "local_ip" {
  description = "The local IP address."
  type        = string
  default     = null
  # validation {
  #   condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.local_ip))
  #   error_message = "local_ip must be a valid IPv4 address (e.g., 192.168.1.1)."
  # }
}

variable "gateway" {
  description = "The gateway IP address."
  type        = string
  default     = null
  # validation {
  #   condition     = var.vlan == null || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", var.gateway))
  #   error_message = "gateway must be a valid IPv4 address (e.g., 192.168.1.1)."
  # }
}

variable "vlan" {
  description = "The VLAN ID to be used. Must be null or an integer between 1 and 4094."
  type        = number
  default     = null
  # validation {
  #   condition     = var.vlan == null || (var.vlan >= 1 && var.vlan <= 4094)
  #   error_message = "vlan must be null or an integer between 1 and 4094."
  # }
}

variable "internet_only" {
  description = "If true, the network range will only have internet access and no internal routing."
  type        = bool
  default     = false
}

variable "mdns_reflector" {
  description = "Enable or disable mDNS reflector for this network range."
  type        = bool
  default     = false
}

variable "translated_subnet" {
  description = "The translated subnet in CIDR notation for NAT configuration."
  type        = string
  default     = null
}

variable "dhcp_settings" {
  description = "DHCP settings for the network range. Only applicable if range_type is VLAN or Native."
  type = object({
    dhcp_type              = string
    ip_range               = optional(string, null) # Optional field for IP range
    relay_group_id         = optional(string, null) # Optional field for relay group ID
    relay_group_name       = optional(string, null) # Optional field for relay group name
    dhcp_microsegmentation = optional(bool, false)  # Optional field for microsegmentation
  })
  default = null
}

# =============================================================================
# NETWORK RANGE OUTPUTS
# =============================================================================

# Combined network range resource (either with or without DHCP)
output "network_range" {
  description = "The created network range resource (either with DHCP or without DHCP)"
  value = var.dhcp_settings != null ? (
    length(cato_network_range.with_dhcp) > 0 ? cato_network_range.with_dhcp[0] : null
  ) : (
    length(cato_network_range.no_dhcp) > 0 ? cato_network_range.no_dhcp[0] : null
  )
}

# =============================================================================
# NETWORK RANGE IDENTIFICATION
# =============================================================================

output "id" {
  description = "The unique identifier of the network range"
  value = var.dhcp_settings != null ? (
    length(cato_network_range.with_dhcp) > 0 ? cato_network_range.with_dhcp[0].id : null
  ) : (
    length(cato_network_range.no_dhcp) > 0 ? cato_network_range.no_dhcp[0].id : null
  )
}

output "name" {
  description = "The name of the network range"
  value = var.name
}

output "subnet" {
  description = "The subnet in CIDR notation"
  value = var.subnet
}

output "range_type" {
  description = "The type of network range (Direct, Native, Routed, SecondaryNative, VLAN)"
  value = var.range_type
}

# =============================================================================
# NETWORK CONFIGURATION
# =============================================================================

output "site_id" {
  description = "The site ID where the network range is created"
  value = var.site_id
}

output "interface_id" {
  description = "The interface ID assigned to the network range"
  value = var.interface_id
}

output "interface_index" {
  description = "The interface index assigned to the network range"
  value = var.interface_index
}

output "local_ip" {
  description = "The local IP address of the network range"
  value = var.local_ip
}

output "gateway" {
  description = "The gateway IP address of the network range"
  value = var.gateway
}

output "vlan" {
  description = "The VLAN ID assigned to the network range"
  value = var.vlan
}

output "translated_subnet" {
  description = "The translated subnet for NAT configuration"
  value = var.translated_subnet
}

# =============================================================================
# NETWORK FEATURES
# =============================================================================

output "internet_only" {
  description = "Whether the network range has internet-only access"
  value = var.internet_only
}

output "mdns_reflector" {
  description = "Whether mDNS reflector is enabled for the network range"
  value = var.range_type != "Routed" ? var.mdns_reflector : false
}

# =============================================================================
# DHCP CONFIGURATION
# =============================================================================

output "has_dhcp" {
  description = "Whether the network range has DHCP configuration"
  value = var.dhcp_settings != null
}

output "dhcp_settings" {
  description = "The DHCP settings configured for the network range"
  value = var.dhcp_settings
}

output "dhcp_type" {
  description = "The DHCP type configured (DHCP_DISABLED, ACCOUNT_DEFAULT, DHCP_RELAY, DHCP_RANGE)"
  value = var.dhcp_settings != null ? var.dhcp_settings.dhcp_type : null
}

output "dhcp_ip_range" {
  description = "The IP range configured for DHCP_RANGE type"
  value = var.dhcp_settings != null ? var.dhcp_settings.ip_range : null
}

output "dhcp_relay_group_id" {
  description = "The DHCP relay group ID configured for DHCP_RELAY type"
  value = var.dhcp_settings != null ? var.dhcp_settings.relay_group_id : null
}

output "dhcp_relay_group_name" {
  description = "The DHCP relay group name configured for DHCP_RELAY type"
  value = var.dhcp_settings != null ? var.dhcp_settings.relay_group_name : null
}

output "dhcp_microsegmentation" {
  description = "Whether DHCP microsegmentation is enabled"
  value = var.dhcp_settings != null ? var.dhcp_settings.dhcp_microsegmentation : false
}

# =============================================================================
# RAW RESOURCE OUTPUTS (for advanced use cases)
# =============================================================================

output "network_range_with_dhcp" {
  description = "Raw output of the network range resource with DHCP settings (empty list if not applicable)"
  value = cato_network_range.with_dhcp[*]
}

output "network_range_no_dhcp" {
  description = "Raw output of the network range resource without DHCP settings (empty list if not applicable)"
  value = cato_network_range.no_dhcp[*]
}

# =============================================================================
# METADATA
# =============================================================================

output "resource_type" {
  description = "The type of resource created (with_dhcp or no_dhcp)"
  value = var.dhcp_settings != null ? "with_dhcp" : "no_dhcp"
}

output "configuration_summary" {
  description = "A summary of the key network range configuration"
  value = {
    name               = var.name
    subnet             = var.subnet
    range_type         = var.range_type
    site_id            = var.site_id
    interface_index    = var.interface_index
    has_dhcp           = var.dhcp_settings != null
    dhcp_type          = var.dhcp_settings != null ? var.dhcp_settings.dhcp_type : null
    internet_only      = var.internet_only
    mdns_reflector     = var.range_type != "Routed" ? var.mdns_reflector : false
    translated_subnet  = var.translated_subnet
    vlan               = var.vlan
  }
}

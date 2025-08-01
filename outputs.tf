# =============================================================================
# MAIN MODULE OUTPUTS - TERRAFORM CATO NETWORK RANGES BULK
# =============================================================================

# =============================================================================
# NETWORK RANGES COLLECTION
# =============================================================================

output "network_ranges" {
  description = "Map of all created network range resources, keyed by subnet"
  value = {
    for subnet, range in module.network_range : subnet => range.network_range
  }
}

output "network_range_ids" {
  description = "Map of network range IDs, keyed by subnet"
  value = {
    for subnet, range in module.network_range : subnet => range.id
  }
}

output "network_range_names" {
  description = "Map of network range names, keyed by subnet"
  value = {
    for subnet, range in module.network_range : subnet => range.name
  }
}

# =============================================================================
# CONFIGURATION SUMMARIES
# =============================================================================

output "configuration_summary" {
  description = "Summary of all network range configurations"
  value = {
    for subnet, range in module.network_range : subnet => range.configuration_summary
  }
}

output "network_ranges_by_type" {
  description = "Network ranges grouped by range type"
  value = {
    for range_type in distinct([for range in module.network_range : range.range_type]) :
    range_type => {
      for subnet, range in module.network_range : subnet => range.configuration_summary
      if range.range_type == range_type
    }
  }
}

output "network_ranges_by_site" {
  description = "Network ranges grouped by site ID"
  value = {
    for site_id in distinct([for range in module.network_range : range.site_id]) :
    site_id => {
      for subnet, range in module.network_range : subnet => range.configuration_summary
      if range.site_id == site_id
    }
  }
}

# =============================================================================
# DHCP CONFIGURATION OUTPUTS
# =============================================================================

output "dhcp_enabled_ranges" {
  description = "Network ranges that have DHCP configuration enabled"
  value = {
    for subnet, range in module.network_range : subnet => {
      id            = range.id
      name          = range.name
      dhcp_type     = range.dhcp_type
      dhcp_settings = range.dhcp_settings
    }
    if range.has_dhcp
  }
}

output "dhcp_disabled_ranges" {
  description = "Network ranges that have DHCP disabled or no DHCP configuration"
  value = {
    for subnet, range in module.network_range : subnet => {
      id   = range.id
      name = range.name
    }
    if !range.has_dhcp
  }
}

output "dhcp_ranges_by_type" {
  description = "DHCP-enabled network ranges grouped by DHCP type"
  value = {
    for dhcp_type in distinct([for range in module.network_range : range.dhcp_type if range.has_dhcp]) :
    dhcp_type => {
      for subnet, range in module.network_range : subnet => {
        id                      = range.id
        name                    = range.name
        dhcp_ip_range          = range.dhcp_ip_range
        dhcp_relay_group_id    = range.dhcp_relay_group_id
        dhcp_relay_group_name  = range.dhcp_relay_group_name
        dhcp_microsegmentation = range.dhcp_microsegmentation
      }
      if range.has_dhcp && range.dhcp_type == dhcp_type
    }
  }
}

# =============================================================================
# NETWORK FEATURES
# =============================================================================

output "internet_only_ranges" {
  description = "Network ranges configured for internet-only access"
  value = {
    for subnet, range in module.network_range : subnet => {
      id   = range.id
      name = range.name
    }
    if range.internet_only
  }
}

output "mdns_reflector_ranges" {
  description = "Network ranges with mDNS reflector enabled"
  value = {
    for subnet, range in module.network_range : subnet => {
      id         = range.id
      name       = range.name
      range_type = range.range_type
    }
    if range.mdns_reflector
  }
}

output "translated_subnet_ranges" {
  description = "Network ranges with NAT translation configured"
  value = {
    for subnet, range in module.network_range : subnet => {
      id                = range.id
      name              = range.name
      original_subnet   = range.subnet
      translated_subnet = range.translated_subnet
    }
    if range.translated_subnet != null
  }
}

output "vlan_ranges" {
  description = "Network ranges configured with VLAN IDs"
  value = {
    for subnet, range in module.network_range : subnet => {
      id   = range.id
      name = range.name
      vlan = range.vlan
    }
    if range.vlan != null
  }
}

# =============================================================================
# INTERFACE MAPPINGS
# =============================================================================

output "ranges_by_interface" {
  description = "Network ranges grouped by interface index"
  value = {
    for interface_index in distinct([for range in module.network_range : range.interface_index]) :
    interface_index => {
      for subnet, range in module.network_range : subnet => {
        id          = range.id
        name        = range.name
        range_type  = range.range_type
        subnet      = range.subnet
      }
      if range.interface_index == interface_index
    }
  }
}

# =============================================================================
# STATISTICS AND COUNTS
# =============================================================================

output "total_ranges_created" {
  description = "Total number of network ranges created"
  value = length(module.network_range)
}

output "ranges_count_by_type" {
  description = "Count of network ranges by type"
  value = {
    for range_type in distinct([for range in module.network_range : range.range_type]) :
    range_type => length([
      for range in module.network_range : range
      if range.range_type == range_type
    ])
  }
}

output "dhcp_count_by_type" {
  description = "Count of DHCP configurations by type"
  value = merge(
    {
      "no_dhcp" = length([for range in module.network_range : range if !range.has_dhcp])
    },
    {
      for dhcp_type in distinct([for range in module.network_range : range.dhcp_type if range.has_dhcp]) :
      dhcp_type => length([
        for range in module.network_range : range
        if range.has_dhcp && range.dhcp_type == dhcp_type
      ])
    }
  )
}

output "feature_usage_stats" {
  description = "Statistics on feature usage across all network ranges"
  value = {
    total_ranges          = length(module.network_range)
    internet_only_count   = length([for range in module.network_range : range if range.internet_only])
    mdns_reflector_count  = length([for range in module.network_range : range if range.mdns_reflector])
    translated_subnet_count = length([for range in module.network_range : range if range.translated_subnet != null])
    vlan_configured_count = length([for range in module.network_range : range if range.vlan != null])
    dhcp_enabled_count    = length([for range in module.network_range : range if range.has_dhcp])
  }
}

# =============================================================================
# PROCESSED INPUT DATA
# =============================================================================

output "processed_network_ranges" {
  description = "The processed network range data from input (for debugging/verification)"
  value = local.network_ranges
  sensitive = false
}

output "input_data_count" {
  description = "Number of network range entries processed from input data"
  value = length(var.network_range_data)
}

# =============================================================================
# VALIDATION AND DEBUGGING
# =============================================================================

output "creation_summary" {
  description = "Summary of the bulk network range creation process"
  value = {
    input_records_count    = length(var.network_range_data)
    processed_records_count = length(local.network_ranges)
    created_ranges_count   = length(module.network_range)
    sites_involved         = distinct([for range in module.network_range : range.site_id])
    interfaces_used        = distinct([for range in module.network_range : range.interface_index])
    range_types_created    = distinct([for range in module.network_range : range.range_type])
    dhcp_types_used        = distinct(compact([for range in module.network_range : range.dhcp_type]))
  }
}

# =============================================================================
# RAW MODULE OUTPUTS (for advanced use cases)
# =============================================================================

output "raw_module_outputs" {
  description = "Raw outputs from all network range submodules (for advanced use cases)"
  value = module.network_range
  sensitive = false
}

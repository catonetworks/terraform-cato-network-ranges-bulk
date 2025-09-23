resource "cato_network_range" "with_dhcp" {
  ## If dhcp_settings is null then don't build (count = 0, else count=1)
  count              = var.dhcp_settings == null ? 0 : 1
  site_id            = var.site_id
  interface_id       = var.interface_id
  interface_index    = var.interface_id == null ? var.interface_index : null
  name               = var.name
  range_type         = var.range_type
  subnet             = var.subnet
  local_ip           = var.local_ip
  gateway            = var.gateway
  vlan               = var.vlan
  translated_subnet  = var.translated_subnet
  internet_only      = var.internet_only
  
  # Only include mdns_reflector for non-Routed subnets
  mdns_reflector     = var.range_type != "Routed" ? var.mdns_reflector : null
  
  dhcp_settings = {
    dhcp_type              = var.dhcp_settings.dhcp_type
    ip_range               = var.dhcp_settings.dhcp_type != "DHCP_DISABLED" && var.dhcp_settings.ip_range != null && var.dhcp_settings.ip_range != "" ? var.dhcp_settings.ip_range : null
    relay_group_id         = var.dhcp_settings.dhcp_type == "DHCP_RELAY" && var.dhcp_settings.relay_group_id != null && var.dhcp_settings.relay_group_id != "" ? var.dhcp_settings.relay_group_id : null
    relay_group_name       = var.dhcp_settings.dhcp_type == "DHCP_RELAY" && var.dhcp_settings.relay_group_name != null && var.dhcp_settings.relay_group_name != "" ? var.dhcp_settings.relay_group_name : null
    dhcp_microsegmentation = var.dhcp_settings.dhcp_microsegmentation
  }
}

resource "cato_network_range" "no_dhcp" {
  ## If dhcp_settings is null then build (count = 1, else count=0)
  count              = var.dhcp_settings == null ? 1 : 0
  site_id            = var.site_id
  interface_id       = var.interface_id
  interface_index    = var.interface_id == null ? var.interface_index : null
  name               = var.name
  range_type         = var.range_type
  subnet             = var.subnet
  local_ip           = var.local_ip
  gateway            = var.gateway
  vlan               = var.vlan
  translated_subnet  = var.translated_subnet
  internet_only      = var.internet_only
  mdns_reflector     = var.range_type != "Routed" ? var.mdns_reflector : null
}

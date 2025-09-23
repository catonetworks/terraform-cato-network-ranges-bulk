locals {
  network_ranges = [for row in var.network_range_data : {
    id                 = row.id
    site_id            = row.site_id
    interface_id       = try(row.interface_id, null)
    interface_index    = row.interface_index
    name               = row.name
    range_type         = row.range_type
    subnet             = row.subnet
    local_ip           = (row.local_ip != null && row.local_ip != "") ? row.local_ip : null
    gateway            = (row.gateway != null && row.gateway != "") ? row.gateway : null
    vlan               = (row.vlan != null && row.vlan != "") ? tonumber(row.vlan) : null
    translated_subnet  = (row.translated_subnet != null && row.translated_subnet != "") ? row.translated_subnet : null
    internet_only      = row.internet_only == null ? false : (row.internet_only == true || lower(tostring(row.internet_only)) == "true")
    mdns_reflector     = row.mdns_reflector == null ? false : (row.mdns_reflector == true || lower(tostring(row.mdns_reflector)) == "true") && row.range_type != "Routed"
    dhcp_settings = (row.dhcp_type != null && row.dhcp_type != "") ? {
      dhcp_type              = row.dhcp_type
      ip_range               = (row.dhcp_type != "DHCP_DISABLED" && row.dhcp_ip_range != null && row.dhcp_ip_range != "") ? row.dhcp_ip_range : null
      relay_group_id         = (row.dhcp_type == "DHCP_RELAY" && row.dhcp_relay_group_id != null && row.dhcp_relay_group_id != "") ? row.dhcp_relay_group_id : null
      relay_group_name       = (row.dhcp_type == "DHCP_RELAY" && row.dhcp_relay_group_name != null && row.dhcp_relay_group_name != "") ? row.dhcp_relay_group_name : null
      dhcp_microsegmentation = row.dhcp_microsegmentation == null ? false : (row.dhcp_microsegmentation == true || lower(tostring(row.dhcp_microsegmentation)) == "true")
    } : null
  }]
}

module "network_range" {
  source             = "./modules/network_range"
  for_each           = { for idx, network_range in local.network_ranges : "${network_range.interface_index}-${replace(network_range.name, " ", "_")}-${idx}" => network_range }
  
  site_id            = each.value.site_id
  interface_id       = each.value.interface_id
  interface_index    = each.value.interface_index
  name               = each.value.name
  range_type         = each.value.range_type
  subnet             = each.value.subnet
  local_ip           = each.value.local_ip
  gateway            = each.value.gateway
  vlan               = each.value.vlan
  translated_subnet  = each.value.translated_subnet
  internet_only      = each.value.internet_only
  mdns_reflector     = each.value.mdns_reflector
  dhcp_settings      = each.value.dhcp_settings
}

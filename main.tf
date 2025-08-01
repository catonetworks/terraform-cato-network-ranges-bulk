locals {
  network_ranges = [for row in var.network_range_data : {
    site_id            = row.site_id
    interface_index    = row.interface_index
    name               = row.name
    range_type         = row.range_type
    subnet             = row.subnet
    local_ip           = row.local_ip != "" ? row.local_ip : null
    gateway            = row.gateway != "" ? row.gateway : null
    vlan               = row.vlan != "" ? tonumber(row.vlan) : null
    translated_subnet  = row.translated_subnet != "" ? row.translated_subnet : null
    internet_only      = row.internet_only != "" ? lower(row.internet_only) == "true" : false
    mdns_reflector     = (row.mdns_reflector != "" && lower(row.mdns_reflector) == "true" && row.range_type != "Routed") ? true : false
    dhcp_settings = row.dhcp_type != "" ? {
      dhcp_type              = row.dhcp_type
      ip_range               = row.dhcp_ip_range != "" ? row.dhcp_ip_range : null
      relay_group_id         = row.dhcp_relay_group_id != "" ? row.dhcp_relay_group_id : null
      relay_group_name       = row.dhcp_relay_group_name != "" ? row.dhcp_relay_group_name : null
      dhcp_microsegmentation = row.dhcp_microsegmentation != "" ? lower(row.dhcp_microsegmentation) == "true" : false
    } : null
  }]
}

module "network_range" {
  source             = "./modules/network_range"
  for_each           = { for network_range in local.network_ranges : network_range.subnet => network_range }
  
  site_id            = each.value.site_id
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

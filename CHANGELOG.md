# Changelog

## 0.0.1 (2025-08-01)

### Features
- Initial release

## 0.0.2 (2025-08-01)

### Features
- Fixed readme examples

## 0.0.4 (2025-09-11)

### Features
- Upated module to support all available attributes to populate network_ranges including gateway, translated_subnet, etc
- Updated versions files to use latest published provider

## 0.0.5 (2025-09-15)

- Updated versions for specific version of provider 

## 0.0.6 (2025-09-24)
- DHCP Settings: Fixed DHCP relay group processing to only set `relay_group_id` and `relay_group_name` when `dhcp_type` is "DHCP_RELAY"
- DHCP Settings: Fixed `ip_range` field to only be set when `dhcp_type` is not "DHCP_DISABLED"
- API Compatibility: Resolved Cato API error "configuring relayGroupId is allowed only for DHCP_RELAY DHCP type"
- Added comprehensive validation for Routed network ranges to prevent invalid DHCP configuration
- Enhanced support and logic for Routed network ranges
- Improved resource key generation to include index for better uniqueness and resource management

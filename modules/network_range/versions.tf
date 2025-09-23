terraform {
  required_providers {
    cato = {
      source  = "terraform-providers/cato"
      version = "0.0.44"
      # source = "catonetworks/cato"
      # version = ">= 0.0.44"
    }
  }
  required_version = ">= 0.13"
}

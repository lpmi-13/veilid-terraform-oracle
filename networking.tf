
resource "oci_core_vcn" "internal" {
  dns_label  = "veilid"
  cidr_block = "10.0.0.0/16"

  is_ipv6enabled = true
  compartment_id = local.compartment_id
  display_name   = "veilid-network"
}

resource "oci_core_subnet" "internal" {
  cidr_block     = "10.0.0.0/24"
  ipv6cidr_block = cidrsubnet(oci_core_vcn.internal.ipv6cidr_blocks[0], 8, 1)

  compartment_id    = local.compartment_id
  vcn_id            = oci_core_vcn.internal.id
  route_table_id    = oci_core_route_table.route_to_internet.id
  security_list_ids = [oci_core_security_list.ingress.id]

  display_name = "veilid-subnet"
}

resource "oci_core_internet_gateway" "gateway" {
  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.internal.id
}

resource "oci_core_route_table" "route_to_internet" {

  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.internal.id

  route_rules {
    network_entity_id = oci_core_internet_gateway.gateway.id

    description      = "the route out to the public internet - ipv4"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  route_rules {
    network_entity_id = oci_core_internet_gateway.gateway.id

    description      = "the route out to the public internet - ipv6"
    destination      = "::/0"
    destination_type = "CIDR_BLOCK"
  }
}

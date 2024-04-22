
resource "oci_core_security_list" "ingress" {

  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.internal.id

  egress_security_rules {
    destination      = "0.0.0.0/0"
    description      = "let all the packets out - ipv4"
    protocol         = "all"
    stateless        = false
    destination_type = "CIDR_BLOCK"
  }

  egress_security_rules {
    destination      = "::/0"
    description      = "let all the packets out - ipv6"
    protocol         = "all"
    stateless        = false
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol    = "6"
    description = "allow ssh access - ipv4"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    description = "allow ssh access - ipv6"
    source      = "::/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    description = "open port 5150 for TCP connections - ipv4"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 5150
      min = 5150
    }
  }

  ingress_security_rules {
    protocol    = "17"
    description = "open port 5150 for UDP connections - ipv4"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 5150
      min = 5150
    }
  }

  ingress_security_rules {
    protocol    = "6"
    description = "open port 5150 for TCP connections - ipv6"
    source      = "::/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 5150
      min = 5150
    }
  }

  ingress_security_rules {
    protocol    = "17"
    description = "open port 5150 for UDP connections - ipv6"
    source      = "::/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 5150
      min = 5150
    }
  }
}

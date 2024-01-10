terraform {
  required_version = ">= 1.6.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.21.0"
    }
  }
}

# once you have the oci cli set up, run `oci setup config` to generate the security
# token...it will take a bunch of steps, but you'll eventually get there
provider "oci" {
  auth = "SecurityToken"
  # this is the name of the profile, not the path to the file...so if when generating
  # temporary security tokens, they get put in ~/.oci/sessions/temp_profile/token,
  # then your `config_file_profile` will be as shown below.
  # ...if you get logged out, just use `oci session authenticate --no-browser`
  # and type the same profile name when asked
  config_file_profile = "temp_profile"
  region              = local.region
}

locals {
  # at time of writing I have no idea if the free tier is actually sufficient
  # to run 2 nodes, so I guess we'll find out!
  how_many_nodes = 2
  # NOTE: I have no idea if the below compartment_id will work for other accounts, so if it doesn't, follow the instructions below.
  # to find your compartment ID, follow the steps here:
  # https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Locating_Oracle_Cloud_Infrastructure_IDs.htm
  compartment_id = "ocid1.tenancy.oc1..aaaaaaaali33t6j7btx4r5fvo6ip5szccnhy62b6wqjg4bzgcfqotwkjyygq"
  # you can either stick with london, or choose from one of the regions listed here:
  # https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#ad-names
  region = "uk-london-1"
  # there aren't any good docs that just list the availability zones, so the easiest thing to do is
  # to just stick with this one in London...or after you're authenticated with the oci-cli, run:
  # `oci iam availability-domain list | jq '.data[].name'` and just pick one of those.
  availability_domain = "pKgX:UK-LONDON-1-AD-1"
}

# we need all of these networking resources because the terraform config for the
# oci_core_instance requires that we tell it what subnet to be placed in
resource "oci_core_vcn" "internal" {
  dns_label      = "veilid"
  cidr_block     = "10.0.0.0/16"
  compartment_id = local.compartment_id
  display_name   = "veilid-network"
}

resource "oci_core_subnet" "internal" {
  cidr_block        = "10.0.0.0/24"
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

    description      = "the route out to the public internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_security_list" "ingress" {

  compartment_id = local.compartment_id
  vcn_id         = oci_core_vcn.internal.id

  egress_security_rules {
    destination      = "0.0.0.0/0"
    description      = "let all the packets out"
    protocol         = "all"
    stateless        = false
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol    = "6"
    description = "allow ssh access"
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
    description = "open port 5150 for TCP connections"
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
    description = "open port 5150 for UDP connections"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 5150
      min = 5150
    }
  }
}

resource "oci_core_instance" "veilid_node" {
  count = local.how_many_nodes

  availability_domain = local.availability_domain
  compartment_id      = local.compartment_id
  shape               = "VM.Standard.E2.1.Micro"
  display_name        = "veilid-node-${count.index + 1}"

  create_vnic_details {
    subnet_id = oci_core_subnet.internal.id
  }

  source_details {
    # Canonical-Ubuntu-22.04-2023.10.13-0
    # you can technically get the list of images available by compartment ID, but the easiest thing to do is
    # EITHER
    # stick with london and just use the one below
    # OR
    # create a fresh Ubuntu 22.04 instance via the console and click through the image link in
    # instance details to get the OICD, then paste that below
    source_id   = "ocid1.image.oc1.uk-london-1.aaaaaaaanoxok4ypto3xdppngw6jj4km2fpp27snhhotjoybe6bbiizufmlq"
    source_type = "image"

    instance_source_image_filter_details {
      compartment_id = local.compartment_id
    }
  }

  metadata = {
    # make sure you enter your public SSH key here if you want to be able to connect to the instance
    # this will be the key associated with the default 'ubuntu' user
    ssh_authorized_keys = "YOUR_PUBLIC_SSH_KEY_CONTENTS_HERE"
    # this is the cloud init script used to install and configure the veilid-server
    user_data = base64encode(file("./setup-veilid.yaml"))
  }
}

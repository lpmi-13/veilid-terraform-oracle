output "public_ip" {
  value = oci_core_instance.veilid_node[*].public_ip
}

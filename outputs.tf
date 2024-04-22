output "public_ips" {
  value = [for ip in oci_core_instance.veilid_node[*].public_ip : ip]
}

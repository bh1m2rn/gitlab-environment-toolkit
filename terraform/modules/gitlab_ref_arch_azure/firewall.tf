resource "azurerm_network_security_group" "haproxy" {
  name = "${var.prefix}-haproxy-network-security-group"
  location = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name = "icmp"
    description = "Allow Icmp"
    priority = 1002
    direction = "Inbound"
    access = "Allow"
    protocol = "Icmp"
    source_address_prefixes = var.external_ingress_cidr_ranges
    source_port_range = "*"
    destination_address_prefixes = ["*"]
    destination_port_range = "*"
  }

  security_rule {
    name = "tcp"
    description = "Allow traffic on TCP ports: HA Stats, Web, SSH, Prometheus and InfluxDB access"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_address_prefixes = var.external_ingress_cidr_ranges
    source_port_range = "*"
    destination_address_prefixes = ["*"]
    destination_port_ranges = ["22", "1936", "80", "443", "2222", "8086", "9090", "5601"]
  }

  tags = {
    gitlab_node_prefix = var.prefix
    gitlab_node_type = "haproxy"
  }
}

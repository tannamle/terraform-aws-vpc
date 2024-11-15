output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${element(concat(aws_vpc.this.*.cidr_block, list("")), 0)}"
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = "${element(concat(aws_vpc.this.*.default_security_group_id, list("")), 0)}"
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = "${element(concat(aws_vpc.this.*.default_network_acl_id, list("")), 0)}"
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = "${element(concat(aws_vpc.this.*.default_route_table_id, list("")), 0)}"
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = "${element(concat(aws_vpc.this.*.instance_tenancy, list("")), 0)}"
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = "${element(concat(aws_vpc.this.*.enable_dns_support, list("")), 0)}"
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = "${element(concat(aws_vpc.this.*.enable_dns_hostnames, list("")), 0)}"
}

//output "vpc_enable_classiclink" {
//  description = "Whether or not the VPC has Classiclink enabled"
//  value       = "${element(concat(aws_vpc.this.*.enable_classiclink, list("")), 0)}"
//}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = "${element(concat(aws_vpc.this.*.main_route_table_id, list("")), 0)}"
}

//output "vpc_ipv6_association_id" {
//  description = "The association ID for the IPv6 CIDR block"
//  value       = "${element(concat(aws_vpc.this.*.ipv6_association_id, list("")), 0)}"
//}
//
//output "vpc_ipv6_cidr_block" {
//  description = "The IPv6 CIDR block"
//  value       = "${element(concat(aws_vpc.this.*.ipv6_cidr_block, list("")), 0)}"
//}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = ["${aws_vpc_ipv4_cidr_block_association.this.*.cidr_block}"]
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${aws_subnet.private.*.id}"]
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = ["${aws_subnet.private.*.cidr_block}"]
}


output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = ["${aws_subnet.intra.*.id}"]
}

output "intra_subnets_cidr_blocks" {
  description = "List of cidr_blocks of intra subnets"
  value       = ["${aws_subnet.intra.*.cidr_block}"]
}



output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = ["${aws_route_table.private.*.id}"]
}

output "intra_route_table_ids" {
  description = "List of IDs of intra route tables"
  value       = ["${aws_route_table.intra.*.id}"]
}

output "vgw_id" {
  description = "The ID of the VPN Gateway"
  value       = "${element(concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id, list("")), 0)}"
}

output "default_vpc_id" {
  description = "The ID of the VPC"
  value       = "${element(concat(aws_default_vpc.this.*.id, list("")), 0)}"
}

output "default_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = "${element(concat(aws_default_vpc.this.*.cidr_block, list("")), 0)}"
}

output "default_vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = "${element(concat(aws_default_vpc.this.*.default_security_group_id, list("")), 0)}"
}

output "default_vpc_default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = "${element(concat(aws_default_vpc.this.*.default_network_acl_id, list("")), 0)}"
}

output "default_vpc_default_route_table_id" {
  description = "The ID of the default route table"
  value       = "${element(concat(aws_default_vpc.this.*.default_route_table_id, list("")), 0)}"
}

output "default_vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = "${element(concat(aws_default_vpc.this.*.instance_tenancy, list("")), 0)}"
}

output "default_vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = "${element(concat(aws_default_vpc.this.*.enable_dns_support, list("")), 0)}"
}

output "default_vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = "${element(concat(aws_default_vpc.this.*.enable_dns_hostnames, list("")), 0)}"
}

output "default_vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = "${element(concat(aws_default_vpc.this.*.main_route_table_id, list("")), 0)}"
}

# VPC Endpoints
output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = "${element(concat(aws_vpc_endpoint.s3.*.id, list("")), 0)}"
}

output "vpc_endpoint_s3_pl_id" {
  description = "The prefix list for the S3 VPC endpoint."
  value       = "${element(concat(aws_vpc_endpoint.s3.*.prefix_list_id, list("")), 0)}"
}

output "vpc_endpoint_dynamodb_id" {
  description = "The ID of VPC endpoint for DynamoDB"
  value       = "${element(concat(aws_vpc_endpoint.dynamodb.*.id, list("")), 0)}"
}

output "vpc_endpoint_dynamodb_pl_id" {
  description = "The prefix list for the DynamoDB VPC endpoint."
  value       = "${element(concat(aws_vpc_endpoint.dynamodb.*.prefix_list_id, list("")), 0)}"
}

output "vpc_endpoint_ssm_id" {
  description = "The ID of VPC endpoint for SSM"
  value       = "${element(concat(aws_vpc_endpoint.ssm.*.id, list("")), 0)}"
}

output "vpc_endpoint_ssm_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for SSM."
  value       = "${flatten(aws_vpc_endpoint.ssm.*.network_interface_ids)}"
}

output "vpc_endpoint_ssm_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for SSM."
  value       = "${flatten(aws_vpc_endpoint.ssm.*.dns_entry)}"
}

output "vpc_endpoint_ssmmessages_id" {
  description = "The ID of VPC endpoint for SSMMESSAGES"
  value       = "${element(concat(aws_vpc_endpoint.ssmmessages.*.id, list("")), 0)}"
}

output "vpc_endpoint_ssmmessages_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for SSMMESSAGES."
  value       = "${flatten(aws_vpc_endpoint.ssmmessages.*.network_interface_ids)}"
}

output "vpc_endpoint_ssmmessages_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for SSMMESSAGES."
  value       = "${flatten(aws_vpc_endpoint.ssmmessages.*.dns_entry)}"
}

output "vpc_endpoint_ec2_id" {
  description = "The ID of VPC endpoint for EC2"
  value       = "${element(concat(aws_vpc_endpoint.ec2.*.id, list("")), 0)}"
}

output "vpc_endpoint_ec2_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for EC2"
  value       = "${flatten(aws_vpc_endpoint.ec2.*.network_interface_ids)}"
}

output "vpc_endpoint_ec2_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for EC2."
  value       = "${flatten(aws_vpc_endpoint.ec2.*.dns_entry)}"
}

output "vpc_endpoint_ec2messages_id" {
  description = "The ID of VPC endpoint for EC2MESSAGES"
  value       = "${element(concat(aws_vpc_endpoint.ec2messages.*.id, list("")), 0)}"
}

output "vpc_endpoint_ec2messages_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for EC2MESSAGES"
  value       = "${flatten(aws_vpc_endpoint.ec2messages.*.network_interface_ids)}"
}

output "vpc_endpoint_ec2messages_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for EC2MESSAGES."
  value       = "${flatten(aws_vpc_endpoint.ec2messages.*.dns_entry)}"
}

# Static values (arguments)
output "azs" {
  description = "A list of availability zones specified as argument to this module"
  value       = "${var.azs}"
}

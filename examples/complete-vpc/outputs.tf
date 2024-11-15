# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = ["${module.vpc.private_subnets}"]
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = ["${module.vpc.intra_subnets}"]
}


# VPC endpoints
output "vpc_endpoint_ssm_id" {
  description = "The ID of VPC endpoint for SSM"
  value       = "${module.vpc.vpc_endpoint_ssm_id}"
}

output "vpc_endpoint_ssm_network_interface_ids" {
  description = "One or more network interfaces for the VPC Endpoint for SSM."
  value       = ["${module.vpc.vpc_endpoint_ssm_network_interface_ids}"]
}

output "vpc_endpoint_ssm_dns_entry" {
  description = "The DNS entries for the VPC Endpoint for SSM."
  value       = ["${module.vpc.vpc_endpoint_ssm_dns_entry}"]
}

//
//# VPC endpoints
//output "vpc_endpoint_ec2_id" {
//  description = "The ID of VPC endpoint for EC2"
//  value       = "${module.vpc.vpc_endpoint_ec2_id}"
//}
//
//output "vpc_endpoint_ec2_network_interface_ids" {
//  description = "One or more network interfaces for the VPC Endpoint for EC2."
//  value = ["${module.vpc.vpc_endpoint_ec2_network_interface_ids}"]
//}
//
//output "vpc_endpoint_ec2_dns_entry" {
//  description = "The DNS entries for the VPC Endpoint for EC2."
//  value = ["${module.vpc.vpc_endpoint_ec2_dns_entry}"]
//}

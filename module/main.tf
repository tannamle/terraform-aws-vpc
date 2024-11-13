terraform {
  required_version = ">= 0.10.3" # introduction of Local Values configuration language feature
}

locals {
  ##max_subnet_length = "${max(length(var.private_subnets), length(var.elasticache_subnets))}"
  max_subnet_length = "${max(length(var.private_subnets))}"
  vpc_id = "${element(concat(aws_vpc_ipv4_cidr_block_association.this.*.vpc_id, aws_vpc.this.*.id, list("")), 0)}"
}

########################
# VPC creation
########################
resource "aws_vpc" "this" {
  count = "${var.create_vpc ? 1 : 0}"

  cidr_block                       = "${var.cidr}"
  instance_tenancy                 = "${var.instance_tenancy}"
  enable_dns_hostnames             = "${var.enable_dns_hostnames}"
  enable_dns_support               = "${var.enable_dns_support}"
  assign_generated_ipv6_cidr_block = "${var.assign_generated_ipv6_cidr_block}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.vpc_tags)}"
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = "${var.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0}"

  vpc_id = "${aws_vpc.this.id}"

  cidr_block = "${element(var.secondary_cidr_blocks, count.index)}"
}

#########################
# DHCP Options Set
#########################
resource "aws_vpc_dhcp_options" "this" {
  count = "${var.create_vpc && var.enable_dhcp_options ? 1 : 0}"

  domain_name          = "${var.dhcp_options_domain_name}"
  domain_name_servers  = ["${var.dhcp_options_domain_name_servers}"]
  ntp_servers          = ["${var.dhcp_options_ntp_servers}"]
  netbios_name_servers = ["${var.dhcp_options_netbios_name_servers}"]
  netbios_node_type    = "${var.dhcp_options_netbios_node_type}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.dhcp_options_tags)}"
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  count = "${var.create_vpc && var.enable_dhcp_options ? 1 : 0}"

  vpc_id          = "${local.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private" {
  count = "${var.create_vpc && local.max_subnet_length > 0 ? 1 : 1}"

  vpc_id = "${local.vpc_id}"

  #tags = "${merge(map("Name", ("${var.name}-${var.private_subnet_suffix}" : format("%s-${var.private_subnet_suffix}-%s", var.name, element(var.azs, count.index)))), var.tags, var.private_route_table_tags)}"

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = ["propagating_vgws"]
  }
}


#################
# Intra routes
#################
resource "aws_route_table" "intra" {
  count = "${var.create_vpc && length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", "${var.name}-${var.intra_subnet_suffix}"), var.tags, var.intra_route_table_tags)}"
}


#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = "${var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.private_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${var.private_subnet_suffix}-%s", var.name, element(var.azs, count.index))), var.tags, var.private_subnet_tags)}"
}

#####################################################
# intra subnets - private subnet without NAT gateway
#####################################################
resource "aws_subnet" "intra" {
  count = "${var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.intra_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${var.intra_subnet_suffix}-%s", var.name, element(var.azs, count.index))), var.tags, var.intra_subnet_tags)}"
}


##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = "${var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, 0)}"
}


resource "aws_route_table_association" "intra" {
  count = "${var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.intra.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.intra.*.id, 0)}"
}


######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  vpc_id       = "${local.vpc_id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "intra_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint && length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.intra.*.id, 0)}"
}


############################
# VPC Endpoint for DynamoDB
############################
data "aws_vpc_endpoint_service" "dynamodb" {
  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0}"

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0}"

  vpc_id       = "${local.vpc_id}"
  service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = "${var.create_vpc && var.enable_dynamodb_endpoint ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "intra_dynamodb" {
  count = "${var.create_vpc && var.enable_dynamodb_endpoint && length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.intra.*.id, 0)}"
}


#######################
# VPC Endpoint for SSM
#######################
data "aws_vpc_endpoint_service" "ssm" {
  count = "${var.create_vpc && var.enable_ssm_endpoint ? 1 : 0}"

  service = "ssm"
}

resource "aws_vpc_endpoint" "ssm" {
  count = "${var.create_vpc && var.enable_ssm_endpoint ? 1 : 0}"

  vpc_id            = "${local.vpc_id}"
  service_name      = "${data.aws_vpc_endpoint_service.ssm.service_name}"
  vpc_endpoint_type = "Interface"

  security_group_ids  = ["${var.ssm_endpoint_security_group_ids}"]
  subnet_ids          = ["${coalescelist(var.ssm_endpoint_subnet_ids, aws_subnet.private.*.id)}"]
  private_dns_enabled = "${var.ssm_endpoint_private_dns_enabled}"
}

###############################
# VPC Endpoint for SSMMESSAGES
###############################
data "aws_vpc_endpoint_service" "ssmmessages" {
  count = "${var.create_vpc && var.enable_ssmmessages_endpoint ? 1 : 0}"

  service = "ssmmessages"
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count = "${var.create_vpc && var.enable_ssmmessages_endpoint ? 1 : 0}"

  vpc_id            = "${local.vpc_id}"
  service_name      = "${data.aws_vpc_endpoint_service.ssmmessages.service_name}"
  vpc_endpoint_type = "Interface"

  security_group_ids  = ["${var.ssmmessages_endpoint_security_group_ids}"]
  subnet_ids          = ["${coalescelist(var.ssmmessages_endpoint_subnet_ids, aws_subnet.private.*.id)}"]
  private_dns_enabled = "${var.ssmmessages_endpoint_private_dns_enabled}"
}

#######################
# VPC Endpoint for EC2
#######################
data "aws_vpc_endpoint_service" "ec2" {
  count = "${var.create_vpc && var.enable_ec2_endpoint ? 1 : 0}"

  service = "ec2"
}

resource "aws_vpc_endpoint" "ec2" {
  count = "${var.create_vpc && var.enable_ec2_endpoint ? 1 : 0}"

  vpc_id            = "${local.vpc_id}"
  service_name      = "${data.aws_vpc_endpoint_service.ec2.service_name}"
  vpc_endpoint_type = "Interface"

  security_group_ids  = ["${var.ec2_endpoint_security_group_ids}"]
  subnet_ids          = ["${coalescelist(var.ec2_endpoint_subnet_ids, aws_subnet.private.*.id)}"]
  private_dns_enabled = "${var.ec2_endpoint_private_dns_enabled}"
}

###############################
# VPC Endpoint for EC2MESSAGES
###############################
data "aws_vpc_endpoint_service" "ec2messages" {
  count = "${var.create_vpc && var.enable_ec2messages_endpoint ? 1 : 0}"

  service = "ec2messages"
}

resource "aws_vpc_endpoint" "ec2messages" {
  count = "${var.create_vpc && var.enable_ec2messages_endpoint ? 1 : 0}"

  vpc_id            = "${local.vpc_id}"
  service_name      = "${data.aws_vpc_endpoint_service.ec2messages.service_name}"
  vpc_endpoint_type = "Interface"

  security_group_ids  = ["${var.ec2messages_endpoint_security_group_ids}"]
  subnet_ids          = ["${coalescelist(var.ec2messages_endpoint_subnet_ids, aws_subnet.private.*.id)}"]
  private_dns_enabled = "${var.ec2messages_endpoint_private_dns_enabled}"
}

###########################
# VPC Endpoint for ECR API
###########################
data "aws_vpc_endpoint_service" "ecr_api" {
  count = "${var.create_vpc && var.enable_ecr_api_endpoint ? 1 : 0}"

  service = "ecr.api"
}

resource "aws_vpc_endpoint" "ecr_api" {
  count = "${var.create_vpc && var.enable_ecr_api_endpoint ? 1 : 0}"

  vpc_id            = "${local.vpc_id}"
  service_name      = "${data.aws_vpc_endpoint_service.ecr_api.service_name}"
  vpc_endpoint_type = "Interface"

  security_group_ids  = ["${var.ecr_api_endpoint_security_group_ids}"]
  subnet_ids          = ["${coalescelist(var.ecr_api_endpoint_subnet_ids, aws_subnet.private.*.id)}"]
  private_dns_enabled = "${var.ecr_api_endpoint_private_dns_enabled}"
}

###########################
# VPC Endpoint for ECR DKR
###########################
data "aws_vpc_endpoint_service" "ecr_dkr" {
  count = "${var.create_vpc && var.enable_ecr_dkr_endpoint ? 1 : 0}"

  service = "ecr.dkr"
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count = "${var.create_vpc && var.enable_ecr_dkr_endpoint ? 1 : 0}"

  vpc_id            = "${local.vpc_id}"
  service_name      = "${data.aws_vpc_endpoint_service.ecr_dkr.service_name}"
  vpc_endpoint_type = "Interface"

  security_group_ids  = ["${var.ecr_dkr_endpoint_security_group_ids}"]
  subnet_ids          = ["${coalescelist(var.ecr_dkr_endpoint_subnet_ids, aws_subnet.private.*.id)}"]
  private_dns_enabled = "${var.ecr_dkr_endpoint_private_dns_enabled}"
}

#######################
# VPC Endpoint for API Gateway
#######################
data "aws_vpc_endpoint_service" "apigw" {
  count = "${var.create_vpc && var.enable_apigw_endpoint ? 1 : 0}"

  service = "execute-api"
}

resource "aws_vpc_endpoint" "apigw" {
  count = "${var.create_vpc && var.enable_apigw_endpoint ? 1 : 0}"

  vpc_id            = "${local.vpc_id}"
  service_name      = "${data.aws_vpc_endpoint_service.apigw.service_name}"
  vpc_endpoint_type = "Interface"

  security_group_ids  = ["${var.apigw_endpoint_security_group_ids}"]
  subnet_ids          = ["${coalescelist(var.apigw_endpoint_subnet_ids, aws_subnet.private.*.id)}"]
  private_dns_enabled = "${var.apigw_endpoint_private_dns_enabled}"
}


##############
# VPN Gateway
##############
resource "aws_vpn_gateway" "this" {
  count = "${var.create_vpc && var.enable_vpn_gateway ? 1 : 0}"

  vpc_id          = "${local.vpc_id}"
  amazon_side_asn = "${var.amazon_side_asn}"

  tags = "${merge(map("Name", format("%s", var.name)), var.tags, var.vpn_gateway_tags)}"
}

resource "aws_vpn_gateway_attachment" "this" {
  count = "${var.vpn_gateway_id != "" ? 1 : 0}"

  vpc_id         = "${local.vpc_id}"
  vpn_gateway_id = "${var.vpn_gateway_id}"
}


resource "aws_vpn_gateway_route_propagation" "private" {
  count = "${var.create_vpc && var.propagate_private_route_tables_vgw && (var.enable_vpn_gateway || var.vpn_gateway_id != "") ? length(var.private_subnets) : 0}"

  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  vpn_gateway_id = "${element(concat(aws_vpn_gateway.this.*.id, aws_vpn_gateway_attachment.this.*.vpn_gateway_id), count.index)}"
}

###########
# Defaults
###########
resource "aws_default_vpc" "this" {
  count = "${var.manage_default_vpc ? 1 : 0}"

  enable_dns_support   = "${var.default_vpc_enable_dns_support}"
  enable_dns_hostnames = "${var.default_vpc_enable_dns_hostnames}"
  enable_classiclink   = "${var.default_vpc_enable_classiclink}"

  tags = "${merge(map("Name", format("%s", var.default_vpc_name)), var.tags, var.default_vpc_tags)}"
}

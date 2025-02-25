provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "launch_vpc" {
  source = "../modules/vpc"

  vpc_cidr = var.vpc_cidr
  public_subnets_map = var.public_subnets_map
  private_subnets_map = var.private_subnets_map
  tgw_subnets_map = var.tgw_subnets_map
  subnets_bit_length = var.subnets_bit_length
}
resource "aws_route_table" "private_subnet_rtb" {
  depends_on = [module.launch_vpc]
  vpc_id = module.launch_vpc.vpc_id
  tags = {
    Name = "Private Subnets Route Table"
  }
}
resource "aws_route_table_association" "private_rtb_to_private_subnet1" {
  depends_on = [module.launch_vpc, aws_route_table.private_subnet_rtb]
  route_table_id = aws_route_table.private_subnet_rtb.id
  subnet_id = module.launch_vpc.private_subnets_ids_list[0]
}
resource "aws_route_table_association" "private_rtb_to_private_subnet2" {
  depends_on = [module.launch_vpc, aws_route_table.private_subnet_rtb]
  route_table_id = aws_route_table.private_subnet_rtb.id
  subnet_id = module.launch_vpc.private_subnets_ids_list[1]
}
module "tgw_cluster_into_vpc" {
  depends_on = [module.launch_vpc, aws_route_table.private_subnet_rtb]
  source = "../tgw-cross-az-cluster"
  providers = {
    aws = aws
  }

  vpc_id = module.launch_vpc.vpc_id
  public_subnet_1 = module.launch_vpc.public_subnets_ids_list[0]
  public_subnet_2 = module.launch_vpc.public_subnets_ids_list[1]
  private_subnet_1 = module.launch_vpc.private_subnets_ids_list[0]
  private_subnet_2 = module.launch_vpc.private_subnets_ids_list[1]
  tgw_subnet_1_id = module.launch_vpc.tgw_subnets_ids_list[0]
  tgw_subnet_2_id =module.launch_vpc.tgw_subnets_ids_list[1]
  private_route_table = aws_route_table.private_subnet_rtb.id
  gateway_name = var.gateway_name
  gateway_instance_type = var.gateway_instance_type
  key_name = var.key_name
  volume_size = var.volume_size
  volume_encryption = var.volume_encryption
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination = var.disable_instance_termination
  instance_tags = var.instance_tags
  predefined_role = var.predefined_role
  gateway_version = var.gateway_version
  admin_shell = var.admin_shell
  gateway_SICKey = var.gateway_SICKey
  gateway_password_hash = var.gateway_password_hash
  resources_tag_name = var.resources_tag_name
  gateway_hostname = var.gateway_hostname
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  gateway_bootstrap_script = var.gateway_bootstrap_script
  primary_ntp = var.primary_ntp
  secondary_ntp = var.secondary_ntp
  volume_type = var.volume_type
}

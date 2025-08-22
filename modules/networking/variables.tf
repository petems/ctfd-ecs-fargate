variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway (for cost optimization)"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# BYO (Bring Your Own) Resource Support Variables
variable "existing_vpc_id" {
  description = "ID of existing VPC to use (if provided, skips VPC creation)"
  type        = string
  default     = ""
}

variable "existing_public_subnet_ids" {
  description = "IDs of existing public subnets"
  type        = list(string)
  default     = []
}

variable "existing_private_subnet_ids" {
  description = "IDs of existing private subnets"
  type        = list(string)
  default     = []
}

variable "existing_database_subnet_ids" {
  description = "IDs of existing database subnets"
  type        = list(string)
  default     = []
}
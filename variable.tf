variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "availability-zone-1" {}
variable "availability-zone-2" {}

variable "ami-1" {
  description = "My ubuntu ami id"
  default     = "ami-00aa9d3df94c6c354"
}
variable "ami-2" {}
variable "instance_type" {
  description = "My Amazon Linux instance type id"
  default     = "ami-0b0dcb5067f052a63"
}
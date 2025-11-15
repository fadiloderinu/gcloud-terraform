variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "flask-vpc"
}

variable "public_subnet_name" {
  description = "Name of the public subnet"
  type        = string
  default     = "public-subnet"
}

variable "public_subnet_cidr" {
  description = "CIDR range for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
  default     = "private-subnet"
}

variable "private_subnet_cidr" {
  description = "CIDR range for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_name" {
  description = "Name of the Compute Engine instance"
  type        = string
  default     = "flask-backend-instance"
}

variable "machine_type" {
  description = "Machine type for the Compute Engine instance"
  type        = string
  default     = "e2-medium"
}

variable "app_port" {
  description = "Port on which the application runs"
  type        = string
  default     = "5000"
}

variable "container_image" {
  description = "Container image URL"
  type        = string
  default     = "us-docker.pkg.dev/groovy-student-475217-a3/docker-repo/fadil-backend:latest"
}

# Terraform global variables

variable "Name" { default = "nginx-tf" }
variable "Region" { default = "us-central1" }
variable "Zone" { default = "us-central1-c" }
variable "Project" { default = "vm-creating-codelab" }
variable "Tags" { default = [ "http-server", "https-server" ] }
variable "Type" { default = "custom-1-4608"  }
variable "DiskImage" { default = "centos-7-v20200205" }
variable "DiskType" { default = "pd-ssd" }
variable "DiskSize" { default = 30 }
variable "Provision" { default = "sudo yum install -y nginx\nsudo systemctl restart nginx"  }
variable "LabelST" { default = "nginxserver" }
variable "LabelOF" { default = "redhat" }
variable "LabelWay" { default = "tf" }
variable "Network" { default = "default"  }

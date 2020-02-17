# Revise variables.tf for vars

provider "google" {
	credentials = "${file("vm-creating-codelab.json")}"
	project = "${var.Project}"
	region = "${var.Region}"
}

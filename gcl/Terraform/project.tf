provider "google" {

	credentials = "${file("vm-creating-codelab.json")}"

	project = "vm-creating-codelab"

	region = "us-central1"

}

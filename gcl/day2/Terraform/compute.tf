# Revise variables.tf for vars

# Task1

data "google_compute_zones" "available" {}

resource "google_compute_instance" "nginx-tf" {
  name  = "${var.Name}"  
  deletion_protection = true
  project  = "${var.Project}"
  zone  =  "${var.Zone}"
  machine_type  =  "${var.Type}"
  tags  =  "${var.Tags}"

  boot_disk {
    initialize_params {
      image = "${var.DiskImage}"
      type = "${var.DiskType}"
      size = "${var.DiskSize}"
    }
  }

  metadata_startup_script = "${var.Provision}"

  labels {
    servertype = "${var.LabelST}"
    osfamily = "${var.LabelOF}"
    wayofinstallation = "${var.LabelWay}"
}

  network_interface {
    network       = "${var.Network}"
    subnetwork       = "${var.Network}"
    access_config = {}
  }


}

# Output instance IP

output "InstanceIP" {
  value = "http://${google_compute_instance.nginx-tf.network_interface.0.access_config.0.nat_ip}"
}

# Task2

resource "google_compute_disk" "nginx-hdd" {
  name  = "nginx-hdd"
  zone  = "us-central1-c"
  size  = 10
  physical_block_size_bytes = 4096
}

resource "google_compute_attached_disk" "default" {
  disk     = "${google_compute_disk.nginx-hdd.self_link}"
  instance = "${google_compute_instance.nginx-tf.self_link}"
}

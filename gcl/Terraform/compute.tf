data "google_compute_zones" "available" {}

resource "google_compute_instance" "nginx-tf" {
  name	= "${name}"	
	deletion_protection = true
	project	= "${project}"
	zone	=	"${zone}"
  machine_type	=	"${type}"
  tags	=	"${tags}"

  boot_disk {
    initialize_params {
      image = "${disk_image}"
			type = "${disk_type}"
			size = "${disk_size}"
    }
  }

  metadata_startup_script = "${provision}"

	labels {
		servertype = "${label_st}"
		osfamily = "${label_of}"
		wayofinstallation = "${label_way}"
}

  network_interface {
    network       = "${network}"
    access_config = {}
  }
}

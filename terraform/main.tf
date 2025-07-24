resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = var.zone
  size     = "20"
  image_id = "fd8slqa3vkedptmcmgh7"
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"
  zone = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  provisioner "file" {
    source      = "../app"
    destination = "/home/ubuntu/app"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.network_interface[0].nat_ip_address
      }
    }

 provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io docker-compose",
      "sudo usermod -aG docker ubuntu",
      "cd /home/ubuntu/app",
      "sudo docker-compose up -d"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.network_interface[0].nat_ip_address
    }
  }
}




resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}


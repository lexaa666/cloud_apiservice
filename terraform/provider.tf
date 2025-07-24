terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
    #service_account_key_file = "sa-key.json"
    cloud_id = var.cloud_id
    folder_id = var.folder_id
    token =   var.iamtoken
}
source "azure-arm" "ubuntu" {
  resource_group_name = "${managed_image_resource_group_name}"
  storage_account = "${storage_account}"
  subscription_id = "${subscription_id}"
  client_id = "${client_id}"
  client_secret = "${client_secret}"
  tenant_id = "${tenant_id}"

  capture_container_name = "images"
  capture_name_prefix = "packer"

  os_type = "Linux"
  image_publisher = "Canonical"
  image_offer = "UbuntuServer"
  image_sku = "18.04-LTS"

  azure_tags = {
    dept = "demo"
  }

  location = "${location}"
  vm_size = "Standard_D2s_v3"
}

build {
  sources = ["sources.azure-arm.ubuntu"]
}
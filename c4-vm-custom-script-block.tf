resource "azurerm_template_deployment" "terraform-arm" {
  name                = "terraform-arm-01"
  resource_group_name = azurerm_resource_group.provisioner-vm.name

  template_body = file("./module-iis/template.json")

#   parameters = {
#     "storageAccountName" = "terraformarm"
#     "storageAccountType" = "Standard_LRS"

#   }

  deployment_mode = "Incremental"
  depends_on = [ azurerm_windows_virtual_machine.example ]
}
resource "null_resource" "test-WSMan" {
  provisioner "remote-exec" {
    inline = [ 
        "powershell -Command Test-WSMan -ComputerName ${azurerm_public_ip.pip.ip_address}",
     ]
     connection {
      type     = "winrm"
      user     = "adminuser"
      password = "P@$$w0rd1234!"
      host     = azurerm_windows_virtual_machine.example.public_ip_address
      port     = 5985
      https    = false
      timeout  = "3m"
     }
  }
  depends_on = [ azurerm_template_deployment.terraform-arm ]
}

resource "null_resource" "remote-exec" {
  provisioner "remote-exec" {
    inline = [ 
        "powershell -Command Install-WindowsFeature -Name Web-Server",
     ]
     connection {
      type     = "winrm"
      user     = "adminuser"
      password = "P@$$w0rd1234!"
      host     = azurerm_windows_virtual_machine.example.public_ip_address
      port     = 5985
      https    = false
      timeout  = "3m"
     }
  }
  depends_on = [ azurerm_template_deployment.terraform-arm ]
}

resource "null_resource" "file-exec" {
  provisioner "file" {
    source      = "C:\\index.html"
    destination = "C:\\inetpub\\wwwroot\\index.html"
    connection {
      type     = "winrm"
      user     = "adminuser"
      password = "P@$$w0rd1234!"
      host     = azurerm_windows_virtual_machine.example.public_ip_address
      port     = 5985
      https    = false
      timeout  = "3m"
    }
  }
  depends_on = [null_resource.remote-exec]

}
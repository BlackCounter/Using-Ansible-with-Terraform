variable "server_ip" {
  default = "10.0.0.2"
}

variable "wlan_ssid" {
  default = "free wifi hotspot"
}

variable "wlan_psk" {
  default = "changeme"
}

# https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=141834
# https://medium.com/a-swift-misadventure/how-to-setup-your-raspberry-pi-2-3-with-ubuntu-16-04-without-cables-headlessly-9e3eaad32c01
# https://wiki.debian.org/WiFi/HowToUse
resource "null_resource" "wifi" {
  depends_on = ["null_resource.upgrade-packages"]

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${var.server_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y wireless-tools wpasupplicant",
      "cd /lib/firmware/brcm/",
      "sudo wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm80211/brcm/brcmfmac43430-sdio.bin",
      "sudo wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm80211/brcm/brcmfmac43430-sdio.txt",

      "echo \"allow-hotplug wlan0\niface wlan0 inet dhcp\nwpa-conf /etc/wpa_supplicant/wpa_supplicant.conf\" | sudo tee /etc/network/interfaces.d/10-wlan.cfg",
      "echo \"network={\\nssid=\\\"${var.wlan_ssid}\\\"\\npsk=\\\"${var.wlan_psk}\\\"\\n}\" | sudo tee /etc/wpa_supplicant/wpa_supplicant.conf",
      "sudo reboot"
    ]
  }
}
$ terraform apply -target=null_resource.upgrade-packages

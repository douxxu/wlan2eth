# `wlan2eth` - Wi-Fi to Ethernet Sharing Script

The wlan2eth script configures a Raspberry Pi to share its Wi-Fi connection over Ethernet. This script automatically sets up the Raspberry Pi to assign a static IP to the Ethernet interface, configure a DHCP server for connected devices, and enable routing to allow these devices to access the internet via the Raspberry Pi’s Wi-Fi connection.

## Features

- Assigns a static IP to the Ethernet interface (`eth0`).
- Configures a DHCP server to provide IP addresses to devices connected via Ethernet.
- Enables IP forwarding to share the Wi-Fi connection.
- Sets up NAT rules with `iptables` to enable connection sharing.

## Prerequisites

- A Raspberry Pi with a fresh installation of Raspberry Pi OS (or another Debian-based distribution).
- A functional Wi-Fi connection on the Raspberry Pi.
- An Ethernet cable to connect the device to the Raspberry Pi.

## Injecting

To 'inject' wlan2eth in your system, run the following command in your terminal:
```bash
curl -sSL https://douxxu.lain.ch/setups/wlan2eth -o wlan2eth
chmod +x wlan2eth
sudo ./wlan2eth
```


### Command-Line Options

- `-h`, `--help` : Displays a help message with available options.
- `-r`, `--ip-range` : Specifies the DHCP range for the Ethernet interface. The range should be in the format `<ip range start>,<ip range end>`.

   Example to specify a different IP range:

   ```bash
   sudo ./wlan2eth -r 192.168.1.50,192.168.1.150
   ```

>[!WARNING]
> This script will make permanent changes to your Raspberry Pi’s network configuration. It will set a static IP for the Ethernet interface, configure `dnsmasq` for DHCP, and set up routing and NAT rules to share the Wi-Fi connection.

Make sure you understand the implications of these changes before proceeding. You will be prompted to confirm the changes before they are applied.

## Troubleshooting

- **Devices connected to the Ethernet port do not have internet access:** Ensure that the Wi-Fi is working correctly and that the `dnsmasq` and `iptables` configurations are correct. Check the `dnsmasq` logs for clues.

- **The Raspberry Pi does not assign an IP address to Ethernet devices:** Verify that the `dnsmasq` configuration file has been updated correctly and that the `dnsmasq` service is running.

## License

This script is distributed under the GNU General Public License (GPL) version 3. See the [LICENSE](LICENSE) file for details.

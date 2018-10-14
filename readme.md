Mikrotik script to dhcp-to-dns also you needs to provide clients with domain name.
Something like this:

/ip dhcp-server network
add address=192.168.88.0/24 comment="default configuration" dns-server=192.168.88.254 domain=local gateway=192.168.88.1 netmask=24

To automatically run this script each 5 minutes:

/system scheduler
add interval=5m name=dhcp-dns-run on-event=dhcp-dns start-time=00:00:00
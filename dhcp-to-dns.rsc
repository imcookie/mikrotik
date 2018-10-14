:local zone "local"
:local timetolive "00:05:00"
:local hostname
:local ip
:local dnsip
:local dhcpip
:local dnsnode
:local dhcpnode

/ip dns static;
:foreach i in=[find where name ~ (".*\\.".$zone) and ttl ~ $timetolive] do={
  :set hostname [ get $i name ];
  :set hostname [ :pick $hostname 0 ( [ :len $hostname ] - ( [ :len $zone ] + 1 ) ) ];
  /ip dhcp-server lease;
  :set dhcpnode [ find where host-name=$hostname ];
  :if ( [ :len $dhcpnode ] > 0) do={
    :log debug ("Lease for ".$hostname." still exists. Not deleting.");
  } else={
    :log info ("Lease expired for ".$hostname.", deleting DNS entry.");
    /ip dns static remove $i;
  }
}

/ip dhcp-server lease;
:foreach i in=[find] do={
  :set hostname ""
  :local mac
  :set dhcpip [ get $i address ];
  :set mac [ get $i mac-address ];
  :if ( [ :len $hostname ] = 0) do={
    :set hostname [ get $i host-name ];
  }
  :if ( [ :len $hostname ] > 0) do={
    :set hostname ( $hostname . "." . $zone );
    /ip dns static;
    :set dnsnode [ find where name=$hostname ];
    :if ( [ :len $dnsnode ] > 0 ) do={
# it exists. Is its IP the same
      :set dnsip [ get $dnsnode address ];
      :if ( $dnsip = $dhcpip ) do={
        :log debug ("DNS entry for " . $hostname . " does not need updating.");
      } else={
        :log info ("Replacing DNS entry for " . $hostname);
        /ip dns static remove $dnsnode;
        /ip dns static add name=$hostname address=$dhcpip ttl=$timetolive;
      }
    } else={
# it doesnt exist. Add it
      :log info ("Adding new DNS entry for " . $hostname);
      /ip dns static add name=$hostname address=$dhcpip ttl=$timetolive;
    }
  }
}
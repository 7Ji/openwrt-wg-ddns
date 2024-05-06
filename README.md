# OpenWrt WireGuard DynDNS updater

WireGuard only accepts endpoints with static IPs. If the config of endpoint contains a domain, then the domain would be resolved before it's used.

That works well until you have an endpoint with DynDNS whose underlying IPs change a lot. In that case, the endpoint IP won't be updated, and after an IP update of that DynDNS domain, the connection to that very endpoint would become impossible.

This works by using dig to resolve endpoint IPs per minute, and update the endpoint config to the latest resolved IPs. 

By default, this runs with a 60 seconds interval.
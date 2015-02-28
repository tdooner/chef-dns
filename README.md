chef-dns (Chef-based DNS Server)
============================

This is a proof-of-concept DNS server that forwards all DNS queries to a Chef
server and responds with the most up-to-date information about the node.

Potentially, this could be run as a service on nameservers, and BIND configured
to "forward" specified zones to this service. This would result in BIND caching
the results so as to not overload the Chef API.

# Setup
You're going to have to manually edit the strings in lib/chef-dns/server.rb to
point to your API client.pem and your trusted_cert if you use a self-signed
certificate for your Chef server.

## Benefits
* Your DNS results always reflect reality (+/- one TTL)

## Drawbacks
* This needs some caching -- results take ~400 ms and doing this at production
  volume could overload the Chef server
* When the Chef server goes down, you lose the ability to resolve domain names
  (+/- one TTL)
* DNSSEC is going to be very difficult to implement
* The Ruby DNS server doesn't support many things that could make this work
  better, such as SSHFP records and zone transfers

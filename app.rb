require 'chef-api'
require 'rubydns'
require 'uri'
require 'ipaddr'

ChefAPI.configure do |config|
  config.endpoint = 'https://chef.brigade.com/'
  config.client = 'tom-test-dns'
  config.key = '/mnt/ssd/tom/dev/ruby/chef-dns/client.pem'
end

OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE.add_file('/mnt/ssd/tom/dev/ruby/chef-dns/chef_brigade_com.crt')

class ChefServer < RubyDNS::RuleBasedServer
  IN = Resolv::DNS::Resource::IN

  def process(name, resource_class, transaction)
    if resource_class == IN::A
      node = ChefAPI::Resource::Node.fetch(name)

      transaction.respond!(node.automatic['ipaddress'], ttl: 60)
    elsif resource_class == IN::PTR
      ipaddress = name.split('.')[0..3].reverse.join('.')
      results = ChefAPI::Resource::Search.query('node', "ipaddress:#{ipaddress}")

      fqdn = results.rows.first['automatic']['fqdn']

      transaction.respond!(Resolv::DNS::Name.create(fqdn), ttl: 60)
    end
  end
end

RubyDNS::run_server(asynchronous: false, server_class: ChefServer, listen: [[:udp, '0.0.0.0', 5300]])

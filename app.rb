require 'chef-api'
require 'rubydns'
require 'uri'
require 'ipaddr'

ChefAPI.configure do |config|
  config.endpoint = 'https://chef.brigade.com/'
  config.flavor = :open_source
  config.client = 'tom-test-dns'
  config.key = '/mnt/ssd/tom/dev/ruby/chef-dns/client.pem'
  config.ssl_verify = false
end

class ChefServer < RubyDNS::RuleBasedServer
  IN = Resolv::DNS::Resource::IN
  Name = Resolv::DNS::Name

  def initialize(*)
    super
    Thread.new { loop { sleep 5; update_rules } }
  end

  def update_rules
    nodes = ChefAPI::Resource::Search.query('node', 'fqdn:*.iad.brigade.com')

    new_rules = []
    nodes.rows.each do |node|
      puts "Registering node #{node['automatic']['fqdn']}"

      new_rules << Rule.new([node['automatic']['fqdn'], IN::A], ->(t) do
        t.respond!(node['automatic']['ipaddress'], ttl: 60)
      end)

      new_rules << Rule.new([IPAddr.new(node['automatic']['ipaddress']).reverse, IN::PTR], ->(t) do
        t.respond!(Name.create(node['automatic']['fqdn']), ttl: 60)
      end)
    end

    @rules = new_rules
  end
end

RubyDNS::run_server(asynchronous: false, server_class: ChefServer, listen: [[:udp, '0.0.0.0', 5300]])

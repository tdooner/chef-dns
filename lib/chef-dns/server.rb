require 'rubydns'
require 'uri'
require 'ipaddr'
require 'chef-api'

ChefAPI.configure do |config|
  config.endpoint = 'https://chef.brigade.com/'
  config.client = 'tom-test-dns'
  config.key = '/mnt/ssd/tom/dev/ruby/chef-dns/client.pem'
end

OpenSSL::SSL::SSLContext::DEFAULT_CERT_STORE.add_file('/mnt/ssd/tom/dev/ruby/chef-dns/chef_brigade_com.crt')

module ChefDNS
  class Server < RubyDNS::RuleBasedServer
    IN = Resolv::DNS::Resource::IN

    CACHE = ChefCache.new

    def process(name, resource_class, transaction)

      records = ChefDNS::RecordFinder::FINDER_REGISTRY[resource_class].flat_map do |finder|
        finder.find_records(name)
      end

      records.each do |record|
        transaction.respond!(record, ttl: 60)
      end
    end

    def run!
      RubyDNS::run_server(
        asynchronous: false,
        server_class: self.class,
        listen: [[:udp, '0.0.0.0', 5300]],
      )
    end
  end
end

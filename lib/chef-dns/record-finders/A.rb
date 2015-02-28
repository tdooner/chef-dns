require 'resolv'

module ChefDNS
  module RecordFinders
    class A < ChefDNS::RecordFinder
      register_finder self, Resolv::DNS::Resource::IN::A

      def find_records(query)
        node = ChefAPI::Resource::Node.fetch(query)

        Resolv::IPv4.create(node.automatic['ipaddress'])
      end
    end
  end
end

module ChefDNS
  module RecordFinders
    class PTR < ChefDNS::RecordFinder
      register_finder self, Resolv::DNS::Resource::IN::PTR

      def find_records(query)
        ipaddress = query.split('.')[0..3].reverse.join('.')
        res = ChefAPI::Resource::Search.query('node', "ipaddress:#{ipaddress}")

        Resolv::DNS::Name.create(res.rows.first['automatic']['fqdn'])
      end
    end
  end
end

module ChefDNS
  class RecordFinder
    FINDER_REGISTRY = {}

    # @return [Array] Records
    def find_records(node)
      raise NotImplementedException
    end

    protected

    def self.register_finder(klass, type)
      FINDER_REGISTRY[type] ||= []
      FINDER_REGISTRY[type] << klass.new
    end
  end
end

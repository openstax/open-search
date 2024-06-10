module Books::SearchStrategies::S2
  class Strategy < Books::SearchStrategies::Base

    SUPPORTED_INDEX_STRATEGIES = [
      Books::IndexingStrategies::I2::Strategy,
      Books::IndexingStrategies::I3::Strategy
    ].map(&:short_name)

    def self.short_name
      "s2"
    end

    def initialize(index_names:, options: {})
      @options = options
      super(index_names: index_names)
    end

    def self.supports_index_strategy?(name)
      SUPPORTED_INDEX_STRATEGIES.include?(name.downcase)
    end

    protected

    def search_body(query_string)
      # query_string = single_quotes_to_double(query_string)

      {
        size: 1,
        query: {
          multi_match: {
            fields: %w(versionedOrn^2 orn),
            operator: 'AND',
            query: query_string
          }
        }
      }
    end
  end
end

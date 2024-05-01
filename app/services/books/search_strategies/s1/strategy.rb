module Books::SearchStrategies::S1
  class Strategy < Books::SearchStrategies::Base

    SUPPORTED_INDEX_STRATEGIES = [
      Books::IndexingStrategies::I1::Strategy,
      Books::IndexingStrategies::I2::Strategy,
      Books::IndexingStrategies::I3::Strategy
    ].map(&:short_name)

    MAX_SEARCH_RESULTS = 1000

    def self.short_name
      "s1"
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
        size: MAX_SEARCH_RESULTS,
        query: {
          multi_match: {
            fields: %w(title contextTitle visible_content),
            fuzziness: 'AUTO',
            operator: 'AND',
            prefix_length: 3,
            query: query_string
          }
        },
        track_total_hits: !!@options[:track_total_hits],
        highlight: {
          number_of_fragments: 20,
          pre_tags: ["<strong>"],
          post_tags: ["</strong>"],
          fields: {
            title: {},
            contextTitle: {},
            visible_content: {}
          }
        }
      }
    end

  end
end

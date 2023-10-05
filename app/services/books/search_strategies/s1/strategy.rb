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

    def fuzzify(query_string)
      # 1. Remove ~ and optional suffix from query (to prevent users setting their own fuzziness)
      # 2. Convert smart quotes to normal quotes
      # 3. Split into array of unquoted words and quoted phrases (mismatched quotes are ignored)
      # 4. Add fuzziness to unquoted words only
      # 5. Join array back into a string with spaces
      #
      # Fuzziness values replicate the AUTO fuzziness of other OpenSearch query types
      # simple_query_string doesn't seem to support AUTO fuzziness
      query_string.gsub(/~[^\s"]*/, '').gsub(/“|”/, '"').scan(/[^\s"—–-]+|"[^"]*"/).map do |str|
        next str if str.start_with?('"') || str.length <= 2

        fuzziness = str.length <= 5 ? 1 : 2
        "#{str}~#{fuzziness}"
      end.join(' ')
    end

    def search_body(query_string)
      # query_string = single_quotes_to_double(query_string)

      {
        size: MAX_SEARCH_RESULTS,
        query: {
          simple_query_string: {
            fields: %w(title titleParts contextTitle visible_content),
            query: fuzzify(query_string),
            flags: "FUZZY|PHRASE|WHITESPACE",
            minimum_should_match: "100%",
            default_operator: "AND"
          }
        },
        track_total_hits: !!@options[:track_total_hits],
        highlight: {
          number_of_fragments: 20,
          pre_tags: ["<strong>"],
          post_tags: ["</strong>"],
          fields: {
            title: {},
            titleParts: {},
            contextTitle: {},
            visible_content: {}
          }
        }
      }
    end

  end
end

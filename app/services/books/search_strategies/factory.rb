module Books::SearchStrategies
  class Factory

    INDEXING_CLASSES = [
      Books::IndexingStrategies::I1::Strategy,
      Books::IndexingStrategies::I2::Strategy,
      Books::IndexingStrategies::I3::Strategy
    ].freeze

    NAMES_TO_INDEXING_CLASSES = INDEXING_CLASSES.each_with_object({}) do |klass, hash|
      hash[klass.short_name.downcase] = klass
    end.freeze

    STRATEGY_CLASSES = [
      S1::Strategy,
      S2::Strategy
    ].freeze

    NAMES_TO_STRATEGY_CLASSES = STRATEGY_CLASSES.each_with_object({}) do |klass, hash|
      hash[klass.short_name.downcase] = klass
    end.freeze

    def self.build(index_ids:, index_strategies:, search_strategy:, options: {})
      strategy_class = NAMES_TO_STRATEGY_CLASSES[search_strategy.downcase]

      if strategy_class.nil?
        raise UnknownSearchStrategy, search_strategy
      end

      index_names = []
      index_strategies.each do |index_strategy|
        if !strategy_class.supports_index_strategy?(index_strategy)
          raise IncompatibleStrategies.new(search_strategy: search_strategy, index_strategy: index_strategy)
        end

        indexing_strategy = NAMES_TO_INDEXING_CLASSES[index_strategy]

        index_names.concat(
          index_ids.map do |index_id|
            index = Books::Index.new(index_id: index_id, indexing_strategy: indexing_strategy)
            index.name
          end
        )
      end

      strategy_class.new(index_names: index_names, options: options)
    end

  end
end

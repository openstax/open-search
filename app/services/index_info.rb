class IndexInfo
  DEFAULT_INFO = {
    state:"not found",
    num_docs: "not found"
  }
  BOOK_INDEX_MATCH = /[\w-]+@\w+.+_+.+/

  def call
    @book_indexes = {}
    results
  end

  private

  def results
    {
      es_version: os_version,
      book_indexes: all_the_books
    }
  end

  def os_version
    OxOpenSearchClient.instance.info["version"]["number"]
  end

  def all_the_books
    filtered_os_indices
    dynamo_books
    result = @book_indexes.map{|k,v| v.merge(id: k)}
    result.sort_by{|book_index| book_index[:id]}
  end

  def dynamo_books
    books = BookIndexState.all
    books.each do |book|
      index_name = Books::Index.index_name( index_id: book.index_id, indexing_strategy_short_name: book.indexing_strategy_name)

      update_stat(index: index_name,
                  value_sym: :state,
                  value: book.state)
    end
  end

  def filtered_os_indices
    os_indices = all_os_indices.stats["indices"]
    os_indices.each do |os_index|
      index_name = os_index.first
      if BOOK_INDEX_MATCH.match?(index_name)
        update_stat(index: index_name,
                    value_sym: :num_docs,
                    value: os_index.second["primaries"]["docs"]["count"])

        update_stat(index: index_name,
                    value_sym: :created_at,
                    value: os_created_at(index_name))
      end
    end
  end

  def os_created_at(index_name)
    index = all_os_indices.get(index: index_name)
    os_created_at_ms = index[index_name]["settings"]["index"]["creation_date"]
    Time.at(os_created_at_ms.to_i/1000).utc.iso8601
  end

  def all_os_indices
    @all_os_indices ||= OxOpenSearchClient.instance.indices
  end

  def update_stat(index:, value_sym:, value:)
    stat = @book_indexes.fetch(index, DEFAULT_INFO.dup)
    stat[value_sym] = value
    @book_indexes[index] = stat
  end
end

module Books
  # Books::Index is the main interface into indexing a book.
  #
  # It uses a IndexingStrategy that defines what is indexed including the
  # index's inspect.
  #
  # This class performs the "crud" actions on a book's index.
  class Index
    prefix_logger "Books::Index"

    DEFAULT_INDEXING_STRATEGY = IndexingStrategies::I1::Strategy
    BAD_INDEX_NAME_CHARACTERS = /\//

    class IndexResourceNotReadyError < StandardError; end

    WAIT_UNTIL_MAX_TRIES = 30
    WAIT_UNTIL_TRIES_INTERVAL_SEC = 2

    attr_reader :indexing_strategy

    delegate :index_name, to: :class

    def self.index_name(book_version_id:, indexing_strategy_short_name:)
      raw_name = "#{book_version_id}_#{indexing_strategy_short_name.downcase}"
      raw_name.gsub(BAD_INDEX_NAME_CHARACTERS, '__')
    end

    def initialize(book_version_id: nil, indexing_strategy: DEFAULT_INDEXING_STRATEGY)
      @book_version_id = book_version_id
      @indexing_strategy = indexing_strategy.new
    end

    def with_retry(action_for_log)
      attempt_number = 0

      begin
        attempt_number += 1
        yield
      rescue OpenSearch::Transport::Transport::ServerError => exception
        log_error("#{action_for_log} error, attempt #{attempt_number}: " \
                  "#{exception.class.name} #{exception.message}")
        raise if attempt_number >= 4

        sleep(2 ** attempt_number + 5) unless Rails.env.test?
        retry
      end
    end

    def create(with_wait: true)
      log_debug("create #{name} called")

      with_retry("Index create") do
        OxOpenSearchClient.instance.indices.create(
          index: name,
          body: @indexing_strategy.index_metadata
        )
      end

      wait_until(:exists?) if with_wait
    end

    # This method populates the index with pages from the book
    def populate
      log_debug("populate #{name} called")
      @indexing_strategy.index(book: book, index_name: name)

      index_stats
    end

    def recreate
      delete rescue OpenSearch::Transport::Transport::Errors::NotFound
      create
      populate
    end

    def delete(with_wait: true)
      log_debug("delete #{name} called")
      OxOpenSearchClient.instance.indices.delete(index: name)
      wait_until(:not_exists?) if with_wait
    end

    def name
      index_name(book_version_id: @book_version_id,
                 indexing_strategy_short_name: @indexing_strategy.short_name)
    end

    def exists?
      OxOpenSearchClient.instance.indices.exists?(index: name)
    end

    def not_exists?
      !OxOpenSearchClient.instance.indices.exists?(index: name)
    end

    private

    def wait_until(this_happens)
      tries = 1
      until self.send(this_happens) || tries > WAIT_UNTIL_MAX_TRIES  do
        log_debug("Waiting #{WAIT_UNTIL_TRIES_INTERVAL_SEC} secs for #{name} to #{this_happens.to_s}, num_tries so far: #{tries}")
        sleep(WAIT_UNTIL_TRIES_INTERVAL_SEC)
        tries += 1
      end

      if tries >= WAIT_UNTIL_MAX_TRIES
        raise IndexResourceNotReadyError.new("Books::Index. #{name}:#{this_happens.to_s} failed after #{tries} tries.")
      end

      log_debug("Exiting waiting for #{name} to #{this_happens.to_s} after tries: #{tries}")
    end

    def indices
      @indices ||= OxOpenSearchClient.instance.indices
    end

    def index_stats
      os_stats = OxOpenSearchClient.instance.indices.stats(index: name)
      {
        num_docs_in_index: os_stats["indices"][name]['primaries']['docs']['count'],
        index_name: name
        # todo more stats?
      }
    end

    def get_version
      book.version
    end

    def book
      @book ||= Book.from_id(@book_version_id)
    end
  end
end

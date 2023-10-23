module Books::IndexingStrategies::I2
  class BookDocument
    attr_reader :book

    def self.mapping
      { title: { type: 'text' } }
    end

    def initialize(book:)
      @book = book
    end

    def orn_domain
      Rails.application.secrets.orn_domain
    end

    def body
      uri = URI("https://#{orn_domain}/orn/book/#{book.uuid}@#{book.version}:#{book.pipeline}.json")

      json = begin
        Net::HTTP.get uri
      rescue
        # Retry the request one time
        Net::HTTP.get uri
      end

      JSON.parse json
    end

    def doc
      @doc ||= body
    end
  end
end

module Books::IndexingStrategies::I3
  # A PageDocument is the index document structure.
  class PageDocument
    attr_reader :page

    def self.mapping
      { contextTitle: { type: 'text' } }
    end

    def initialize(page:)
      @page = page
    end

    def orn_domain
      Rails.application.secrets.orn_domain
    end

    def book
      page.book
    end

    def body
      JSON.parse(
        Net::HTTP.get(
          URI("https://#{orn_domain}/orn/book:page/#{book.uuid}@#{book.version}:#{book.pipeline}:#{page.id.split('@', 2).first}.json")
        )
      )
    end
  end
end

module Books::IndexingStrategies::I3
  # A PageDocument is the index document structure.
  class PageDocument
    attr_reader :page

    def self.mapping
      {
        orn: { type: 'keyword' },
        versionedOrn: { type: 'keyword' },
        contextTitle: { type: 'text' }
      }
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
      uri = URI("https://#{orn_domain}/orn/book:page/#{book.uuid}@#{book.version}:#{book.pipeline}:#{
                page.id.split('@', 2).first}.json?skipCache=true")

      json = begin
        Net::HTTP.get uri
      rescue
        # Retry the request one time
        Net::HTTP.get uri
      end

      JSON.parse json
    end
  end
end

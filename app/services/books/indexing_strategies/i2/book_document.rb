module Books::IndexingStrategies::I2
  class BookDocument
    attr_reader :book

    def self.titlePartsMapping
      {
        titleParts: {
          properties: {
            title: { type: 'text' }
          }
        }
      }
    end

    def self.mapping
      titlePartsMapping.merge(
        contents: {
          properties: titlePartsMapping
        }
      )
    end

    def initialize(book:)
      @book = book
    end

    def orn_domain
      Rails.application.secrets.orn_domain
    end

    def body
      JSON.parse(
        Net::HTTP.get URI("https://#{orn_domain}/orn/book/#{book.uuid}@#{book.version}:#{book.pipeline}.json")
      )
    end

    def docs
      @docs ||= [ body ]
    end
  end
end

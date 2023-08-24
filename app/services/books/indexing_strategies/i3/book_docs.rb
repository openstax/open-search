module Books::IndexingStrategies::I3
  class BookDocs
    def initialize(book:)
      @book = book
    end

    def docs
      @docs ||= @book.root_book_part.pages.map do |page|
        next if page.preface? || page.index?

        PageDocument.new page: page
      end
    end
  end
end

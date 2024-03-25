module Books::IndexingStrategies::I3
  # The indexing strategy is the encapsulation for the index's structure and
  # inspect (including index settings & mappings).
  #
  # The strategy also declares what page element objects it wants indexed.
  class Strategy
    prefix_logger 'Books::IndexingStrategies::I3::Strategy'

    SHORT_NAME = 'i3'
    NUM_SHARDS = 1
    NUM_REPLICAS = 1

    delegate :short_name, to: :class

    def self.short_name
      SHORT_NAME
    end

    def index_metadata(obj:)
      @index_meta ||= {
        settings: settings,
        mappings: mappings
      }
    end

    def index(obj:, index_name:)
      books = obj.books.reverse
      obj.clear_book_cache

      log_info("Creating index #{index_name} with #{books.count} books")

      until books.empty?
        book = books.pop

        documents = Books::IndexingStrategies::I3::BookDocs.new(book: book).docs

        log_info("Adding #{documents.count} page documents for #{book.id}")

        documents.each {|document| index_document(document: document, index_name: index_name) }
      end

      log_info("Finished creating index #{index_name}")
    end

    def total_number_of_documents_to_index(release:)
      release.books.sum { |book| Books::IndexingStrategies::I3::BookDocs.new(book: book).docs.count }
    end

    def model_class
      Rex::Release
    end

    private

    def index_document(document:, index_name:)
      OxOpenSearchClient.instance.index(index: index_name, id: document.body['orn'], body: document.body)
    end

    def settings
      {
        index: {
          number_of_shards: NUM_SHARDS,
          number_of_replicas: NUM_REPLICAS,
          search: {
            slowlog: {
              threshold: {
                query: {
                  warn: '10s'
                },
                fetch: {
                  warn: '1s'
                }
              }
            }
          }
        },
        analysis: {
          analyzer: {
            default: {
              tokenizer: "standard",
              char_filter: [
                "quotes"
              ],
              filter: [
                "lowercase"
              ]
            }
          },
          char_filter: {
            quotes: {
              mappings: [
                "’=>'",
              ],
              type: "mapping"
            }
          }
        }
      }
    end

    def mappings
      { dynamic: false, properties: PageDocument.mapping }
    end
  end
end

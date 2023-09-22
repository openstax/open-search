module Books::IndexingStrategies::I2
  # The indexing strategy is the encapsulation for the index's structure and
  # inspect (including index settings & mappings).
  #
  # The strategy also declares what book objects it wants indexed.
  class Strategy
    prefix_logger 'Books::IndexingStrategies::I2::Strategy'

    SHORT_NAME = 'i2'
    NUM_SHARDS = 1
    NUM_REPLICAS = 1

    delegate :short_name, to: :class

    def self.short_name
      SHORT_NAME
    end

    def index_metadata
      @index_meta ||= {
        settings: settings,
        mappings: mappings
      }
    end

    def index(obj:, index_name:)
      documents = BookDocument.new(book: obj).docs

      log_info("Creating index #{index_name} with #{documents.count} documents")
      documents.each {|document| index_document(document: document, index_name: index_name) }
      log_info("Finished creating index #{index_name}")
    end

    def total_number_of_documents_to_index(book:)
      BookDocument.new(book: book).docs.count
    end

    def model_class
      Rex::Release
    end

    private

    def index_document(document:, index_name:)
      OxOpenSearchClient.instance.index(index: index_name, id: document['orn'], body: document)
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
              tokenizer: 'standard',
              char_filter: [
                'quotes'
              ],
              filter: [
                'lowercase'
              ]
            }
          },
          char_filter: {
            quotes: {
              mappings: [
                "’=>'",
              ],
              type: 'mapping'
            }
          }
        }
      }
    end

    def mappings
      { dynamic: false, properties: BookDocument.mapping }
    end
  end
end

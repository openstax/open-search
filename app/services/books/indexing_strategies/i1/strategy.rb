module Books::IndexingStrategies::I1
  # The indexing strategy is the encapsulation for the index's structure and
  # inspect (including index settings & mappings).
  #
  # The strategy also declares what page element objects it wants indexed.
  class Strategy
    prefix_logger "Books::IndexingStrategies::I1::Strategy"

    SHORT_NAME = "i1"
    NUM_SHARDS = 1
    NUM_REPLICAS = 1

    delegate :short_name, to: :class

    def self.short_name
      SHORT_NAME
    end

    def index_metadata(obj:)
      language = obj.hash.fetch('language', 'en')

      @index_meta = {}
      @index_meta[language] ||= {
        settings: settings(language: language),
        mappings: mappings
      }
    end

    def index(obj:, index_name:)
      documents = Books::IndexingStrategies::I1::BookDocs.new(book: obj).docs

      log_info("Creating index #{index_name} with #{documents.count} documents")
      documents.each {|document| index_document(document: document, index_name: index_name) }
      log_info("Finished creating index #{index_name}")
    end

    def total_number_of_documents_to_index(book:)
      Books::IndexingStrategies::I1::BookDocs.new(book: book).docs.count
    end

    def model_class
      Book
    end

    private

    def index_document(document:, index_name:)
      begin
        OxOpenSearchClient.instance.index(index: index_name, body: document.body)
      rescue ElementIdMissing => ex
        Raven.capture_message(ex.message, :extra => element.to_json)
        log_error(ex)
      end
    end

    def common_settings
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
        }
      }
    end

    def package_ids_secrets
      Rails.application.secrets.open_search[:package_ids]
    end

    def stopwords_secrets
      package_ids_secrets[:stopwords]
    end

    def synonyms_secrets
      package_ids_secrets[:synonyms]
    end

    def en_settings
      common_words = stopwords_secrets[:en].present? ?
        { common_words_path: "analyzers/#{stopwords_secrets[:en]}" } :
        { common_words: '_english_' }

      result = {
        analysis: {
          char_filter: [
            'quotes'
          ],
          filter: {
            english_possessive_stemmer: {
              type: 'stemmer',
              language: 'possessive_english'
            },
            light_english_stemmer: {
              type: 'stemmer',
              language: 'light_english'
            },
            english_index_common: common_words.merge({
              type: 'common_grams'
            }),
            english_search_common: common_words.merge({
              type: 'common_grams',
              query_mode: true
            })
          },
          analyzer: {
            default: {
              tokenizer: 'standard',
              filter: [
                'english_possessive_stemmer',
                'lowercase',
                'light_english_stemmer',
                'asciifolding',
                'english_index_common'
              ]
            },
            default_search: {
              tokenizer: 'standard',
              filter: [
                'english_possessive_stemmer',
                'lowercase',
                'light_english_stemmer',
                'asciifolding',
                'english_search_common'
              ]
            }
          }
        }
      }

      if synonyms_secrets[:en].present?
        result[:analysis][:filter][:english_synonyms] = {
          type: 'synonym_graph',
          synonyms_path: "analyzer/#{synonyms_secrets[:en]}",
          updateable: true
        }

        # Synonyms should happen before search_common, in query mode only
        result[:analysis][:analyzer][:default_search][:filter][-1] = 'english_synonyms'
        result[:analysis][:analyzer][:default_search][:filter] << 'english_search_common'
      end

      result
    end

    def es_settings
      common_words = stopwords_secrets[:es].present? ?
        { common_words_path: "analyzers/#{stopwords_secrets[:es]}" } :
        { common_words: '_spanish_' }

      result = {
        analysis: {
          char_filter: [
            'quotes'
          ],
          filter: {
            light_spanish_stemmer: {
              type: 'stemmer',
              language: 'light_spanish'
            },
            spanish_index_common: common_words.merge({
              type: 'common_grams'
            }),
            spanish_search_common: common_words.merge({
              type: 'common_grams',
              query_mode: true
            })
          },
          analyzer: {
            default: {
              tokenizer: 'standard',
              filter: [
                'lowercase',
                'light_spanish_stemmer',
                'spanish_index_common'
              ]
            },
            default_search: {
              tokenizer: 'standard',
              filter: [
                'lowercase',
                'light_spanish_stemmer',
                'spanish_search_common'
              ]
            }
          }
        }
      }

      if synonyms_secrets[:es].present?
        result[:analysis][:filter][:spanish_synonyms] = {
          type: 'synonym_graph',
          synonyms_path: "analyzer/#{synonyms_secrets[:es]}",
          updateable: true
        }

        # Synonyms should happen before search_common, in query mode only
        result[:analysis][:analyzer][:default_search][:filter][-1] = 'spanish_synonyms'
        result[:analysis][:analyzer][:default_search][:filter] << 'spanish_search_common'
      end

      result
    end

    def pl_settings
      common_words = stopwords_secrets[:pl].present? ?
        { common_words_path: "analyzers/#{stopwords_secrets[:pl]}" } :
        { common_words: '_polish_' }

      result = {
        analysis: {
          char_filter: [
            'quotes'
          ],
          filter: {
            polish_index_common: common_words.merge({
              type: 'common_grams'
            }),
            polish_search_common: common_words.merge({
              type: 'common_grams',
              query_mode: true
            })
          },
          analyzer: {
            default: {
              tokenizer: 'standard',
              filter: [
                'lowercase',
                'polish_stem',
                'polish_index_common'
              ]
            },
            default_search: {
              tokenizer: 'standard',
              filter: [
                'lowercase',
                'polish_stem',
                'polish_search_common'
              ]
            }
          }
        }
      }

      if synonyms_secrets[:pl].present?
        result[:analysis][:filter][:polish_synonyms] = {
          type: 'synonym_graph',
          synonyms_path: "analyzer/#{synonyms_secrets[:pl]}",
          updateable: true
        }

        # Synonyms should happen before search_common, in query mode only
        result[:analysis][:analyzer][:default_search][:filter][-1] = 'polish_synonyms'
        result[:analysis][:analyzer][:default_search][:filter] << 'polish_search_common'
      end

      result
    end

    def settings(language:)
      common_settings.merge send("#{language}_settings")
    end

    def mappings
      { properties: PageElementDocument.mapping }
    end
  end
end

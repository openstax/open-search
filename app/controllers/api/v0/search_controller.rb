class Api::V0::SearchController < Api::V0::BaseController

  EXCEPTIONS_422 = [
    Books::SearchStrategies::UnknownSearchStrategy,
    Books::SearchStrategies::IncompatibleStrategies
  ].freeze

  EXCEPTIONS_422.each do |exception_class|
    rescue_from_unless_local exception_class do |exception|
      render json: binding_error(status_code: 422, messages: [exception.message]), status: 422
    end
  end

  rescue_from_unless_local OpenSearch::Transport::Transport::Errors::NotFound do |_|
    render json: 'The specified resource was not found', status: 404
  end

  swagger_path '/search' do
    operation :get do
      key :summary, 'Run a search query'
      key :description, 'Run a search query'
      key :operationId, 'search'
      parameter do
        key :name, :q
        key :in, :query
        key :description, 'text of the search query'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :books
        key :in, :query
        key :description, 'List of comma-separate UUID@version for the books to search'
        key :required, true
        key :type, :array
        items do
          key :type, :string
        end
      end
      parameter do
        key :name, :index_strategy
        key :in, :query
        key :description, 'name of the index strategy to use when searching'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, :search_strategy
        key :in, :query
        key :description, 'name of the search strategy to use when searching'
        key :required, true
        key :type, :string
      end
      key :tags, [
        'Search'
      ]
      response 200 do
        key :description, 'Success.  Returns the search results.'
        schema do
          key :'$ref', :SearchResult
        end
      end
      extend Api::V0::Swagger::ErrorResponses::UnprocessableEntityError
      extend Api::V0::Swagger::ErrorResponses::ServerError
    end
  end

  PERMITTED_SEARCH_OPTIONS = []

  def search
    started_at = Time.now

    search_strategy_instance = Books::SearchStrategies::Factory.build(
      index_ids: params.require(:books).split(','),
      index_strategies: params.require(:index_strategy).split(','),
      search_strategy: params.require(:search_strategy),
      # V0 API assumes search result counts are always exact
      options: params.permit(*PERMITTED_SEARCH_OPTIONS).merge(track_total_hits: true)
    )

    raw_results = search_strategy_instance.search(query_string: params[:q])

    # #bind now checks for the presence of overall_took so we have to set it before calling it
    raw_results['overall_took'] = ((Time.now - started_at)*1000).round

    hits = raw_results['hits']

    # translate total from OpenSearch object format back to integer for our V0 API
    hits['total'] = hits['total']['value'] if hits.respond_to?(:[]) && hits['total'].respond_to?(:[])

    # some search strategies may not use the "highlight" key but our V0 API requires it
    hits['hits'].each { |hit| hit['highlight'] ||= {} }

    binding, error = bind(raw_results.with_indifferent_access, Api::V0::Bindings::SearchResult)

    if error.nil?
      render json: binding, status: :ok
    else
      render json: error, status: 500
    end
  end
end

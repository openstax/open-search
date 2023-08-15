module Api::V0::Swagger::Models::Info
  include Swagger::Blocks
  include OpenStax::Swagger::SwaggerBlocksExtensions

  swagger_schema :InfoBookIndexResult do
    key :required, [:id, :num_docs]
    property :id do
      key :type, :string
      key :readOnly, true
      key :description, "The ID of the book"
    end
    property :num_docs do
      key :type, :string
      key :readOnly, true
      key :description, "The num of docs in the index"
    end
    property :created_at do
      key :type, :string
      key :readOnly, true
      key :description, "The (OpenSearch) created_at time. Originates in  ISO 8601 format."
    end
    property :state do
      key :type, :string
      key :readOnly, true
      key :description, "The state of the index"
    end
  end
  
  swagger_schema :EsInfoResults do
    key :required, [:overall_took, :es_version]
    property :overall_took_ms do
      key :type, :integer
      key :readOnly, true
      key :description, "How long the request took (ms)"
    end
    property :es_version do
      key :type, :string
      key :readOnly, true
      key :description, "Current version of OpenSearch"
    end
    property :book_indexes do
      key :type, :array
      key :description, "The book indexes"
      items do
        key :'$ref', :InfoBookIndexResult
      end
    end
  end

  swagger_schema :InfoResults do
    key :required, [:overall_took, :env_name, :ami_id, :git_sha]
    property :env_name do
      key :type, :string
      key :readOnly, true
      key :description, "Name of deployed environment"
    end
    property :ami_id do
      key :type, :string
      key :readOnly, true
      key :description, "Amazon machine image id"
    end
    property :git_sha do
      key :type, :string
      key :readOnly, true
      key :description, "Git sha"
    end
    property :overall_took_ms do
      key :type, :integer
      key :readOnly, true
      key :description, "How long the request took (ms)"
    end
  end
end

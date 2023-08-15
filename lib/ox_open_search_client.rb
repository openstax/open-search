require 'opensearch'

class OxOpenSearchClient
  delegate_missing_to :@internal_client

  def self.instance
    Thread.current[:os_client] ||= begin
      secrets = Rails.application.secrets.open_search

      new(
        url: "#{secrets[:protocol]}://#{secrets[:endpoint]}",
        sign_aws_requests: Rails.env.production?
      )
    end
  end

  def initialize(url:, sign_aws_requests: false)
    @internal_client = if sign_aws_requests
      # Borrowed from https://opensearch.org/docs/latest/clients/ruby/#connecting-to-amazon-opensearch-service
      # Also see # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Sigv4/Signer.html
      signer = Aws::Sigv4::Signer.new(service: 'es',
                                      credentials_provider: aws_credentials_provider,
                                      region: aws_open_search_region(url))

      OpenSearch::Aws::Sigv4Client.new(open_search_client_options(url), signer)
    else
      OpenSearch::Client.new(open_search_client_options(url))
    end
  end

  protected

  def open_search_client_options(url)
    {
      url: url,
      log: ENV['INDEXING_HTTP_LOGGING'] == 'true',
      retry_on_failure: 3,
      request_timeout: 60 # default for open_timeout, write_timeout, read_timeout
    }
  end

  def aws_credentials_provider
    # Use credentials from the environment first; if those aren't present, fallback
    # to instance credentials.  Both of these returned objects respond to `#credentials`;
    # in the instance profile case, calling that method returns refreshed credentials.

    if ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'], ENV['AWS_SESSION_TOKEN'])
    else
      Aws::InstanceProfileCredentials.new
    end
  end

  def aws_open_search_region(endpoint_url)
    # AWS OpenSearch endpoint URLs are of the form blah.region.es.amazonaws.com
    # so just extract the region using a regex
    endpoint_url.match(/\.([^\.]*)\.es\.amazonaws\.com$/)[1]
  end
end

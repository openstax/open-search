require 'rails_helper'
require 'vcr_helper'

require 'rex/releases'

RSpec.describe OxOpenSearchClient, vcr: VCR_OPTS do

  before {
    # Even in VCR playback, the code freaks out if these aren't set (in
    # playback, values don't matter)
    ENV['AWS_ACCESS_KEY_ID'] ||= 'foo'
    ENV['AWS_SECRET_ACCESS_KEY'] ||= 'bar'
  }

  let(:fake_os_domain_name) { "spec-esdomain-#{SecureRandom.hex(7)}" }

  it 'can access a restricted AWS OpenSearch domain using signed requests' do
    TempAwsEnv.make do |env|
      domain_status = env.create_open_search_domain(name: fake_os_domain_name)

      signing_client = described_class.new(
        url: "https://#{domain_status.endpoint}",
        sign_aws_requests: true
      )

      resp = signing_client.search q: "test"
      expect(resp).to have_key("took")

      non_signing_client = described_class.new(
        url: "https://#{domain_status.endpoint}",
        sign_aws_requests: false
      )

      expect {
        non_signing_client.search q: "test"
      }.to raise_error(OpenSearch::Transport::Transport::Errors::Forbidden)
    end
  end

end

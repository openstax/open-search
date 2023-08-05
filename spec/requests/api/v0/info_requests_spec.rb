require 'rails_helper'

RSpec.describe 'api v0 info requests', type: :request, api: :v0 do
  let(:stats) {
    {
      es_version: "6.7.2",
      book_indexes: [
        {
          id: "8d50a0af-948b-4204-a71d-4826cba765b8@3bf8607_i1",
          num_docs: "7166",
          state: "create pending"
        },
        {
          id: "a31df062-930a-4f46-8953-605711e6d204@b637022_i1",
          num_docs: "12349", state: "created"
        }
      ]
    }
  }

  before do
    allow_any_instance_of(IndexInfo).to receive(:call).and_return(stats)
  end

  context "#es-info" do
    it "returns info" do
      api_get 'es-info'
      expect(response).to have_http_status(:ok)

      json = json_response
      expect(json[:es_version]).to eq "6.7.2"
      expect(json[:book_indexes].count).to eq 2
    end
  end
end

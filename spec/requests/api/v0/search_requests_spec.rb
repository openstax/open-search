require 'rails_helper'
require 'vcr_helper'

RSpec.describe 'api v0 search requests', type: :request, api: :v0, vcr: VCR_OPTS do
  let(:pipeline) { '20230620.181811' }
  let(:book_id_at_version) { '4fd99458-6fdf-49bc-8688-a6dc17a1268d@f1ce9ea' }
  let(:index_id) { "#{pipeline}/#{book_id_at_version}" }
  let(:indices) do
    Books::SearchStrategies::Factory::INDEXING_CLASSES.map do |indexing_class|
      Books::Index.new(index_id: index_id, indexing_strategy: indexing_class)
    end
  end

  before(:each) do
    do_not_record_or_playback do
      indices.reject(&:exists?).each do |index|
        index.create
        index.populate
      end
    end
  end

  context "#search" do
    it "searches one index" do
      api_get "search?#{query(q: "\"Recall that an atom\"", index_strategy: "i1", search_strategy: "s1")}"
      expect(response).to have_http_status(:ok)

      json = json_response
      expect(json[:overall_took]).not_to be_nil
      expect(json[:hits][:total]).to eq 1
      expect(json[:hits][:hits][0][:_source]).to include(
        page_id: "2c60e072-7665-49b9-a2c9-2736b72b533c@",
        element_type: "paragraph",
        page_position: 4
      )
      expect(json[:hits][:hits][0][:highlight][:visible_content][0]).to start_with "<strong>Recall</strong>"
    end

    it "searches multiple indices" do
      api_get "search?#{query(q: "\"Recall that an atom\"", index_strategy: "i1,i2,i3", search_strategy: "s1")}"
      expect(response).to have_http_status(:ok)

      json = json_response
      expect(json[:overall_took]).not_to be_nil
      expect(json[:hits][:total]).to eq 1
      expect(json[:hits][:hits][0][:_source]).to include(
        page_id: "2c60e072-7665-49b9-a2c9-2736b72b533c@",
        element_type: "paragraph",
        page_position: 4
      )
      expect(json[:hits][:hits][0][:highlight][:visible_content][0]).to start_with "<strong>Recall</strong>"
    end

    it "finds words with apostrophes even if a user uses a different apostrophe" do
      # search?q=person's -> should find person’s
      api_get "search?#{query(q: "person's", index_strategy: "i1", search_strategy: "s1")}"
      expect(response).to have_http_status(:ok)

      json = json_response
      expect(json[:overall_took]).not_to be_nil
      expect(json[:hits][:total]).to eq 37
      expect(json[:hits][:hits][0][:_source]).to include(
        page_id: "6d66e593-841c-55bc-8036-fedc5a6972f9@f1ce9ea",
        element_type: "key_term",
        page_position: 23
      )
      expect(json[:hits][:hits][0][:highlight][:visible_content][0]).to eq "ratio of solutes to a volume of solvent in the plasma; plasma osmolality reflects a <strong>person’s</strong> state of"
    end

    context "client errors" do
      before { render_rescued_exceptions }

      xit "errors for incompatible strategies" do
        # This test should be filled in once we have a real test case for
        # incompatible indexing and search strategies, so we understand better
        # what the problem would be that we'd want to catch.
      end

      it "422s for unknown search strategy" do
        api_get "search?#{query(q: "Blah", index_strategy: "i1", search_strategy: "booyah")}"
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:messages]).to include(/Unknown search strategy: booyah/)
      end

      it "404s for unknown resource" do
        api_get "search?#{query(q: "Blah", book_id: 'foobar', index_strategy: "i1", search_strategy: "s1")}"
        expect(response).to have_http_status(404)
        expect(response.body).to include('The specified resource was not found')
      end

      it "422's for missing params" do
        api_get "search?q=blah"
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:messages]).to include(/or the value is empty: book/)
      end
    end

    context 'server errors' do
      it "500's for invalid response from OpenSearch" do
        expect_any_instance_of(Books::SearchStrategies::S1::Strategy).to(
          receive(:search).and_return(
            # This is the valid response with hits: { total: 1 }, removed to make it invalid
            {
              took: 156,
              timed_out: false,
              _shards: { total: 1, successful: 1, skipped: 0, failed: 0 },
              hits: {
                max_score: 9.082203,
                hits: [
                  {
                    _index: '4fd99458-6fdf-49bc-8688-a6dc17a1268d@f1ce9ea_i1',
                    _type: 'page_element',
                    _id: 'bskMq2wB2NuZq8GSEI5w',
                    _score: 9.082203,
                    _source: {
                      page_id: '2c60e072-7665-49b9-a2c9-2736b72b533c@',
                      element_id: 'fs-id2113058',
                      element_type: 'paragraph',
                      page_position: 4
                    },
                    highlight: {
                      visible_content: [
                        '<strong>Recall</strong>
                <strong>that</strong> <strong>an</strong> <strong>atom</strong> typically
                has the same number of positively charged protons and negatively charged'
                      ]
                    }
                  }
                ]
              }
            }.deep_stringify_keys
          )
        )
        api_get "search?#{
          query(q: "\"Recall that an atom\"", index_strategy: "i1", search_strategy: "s1")
        }"
        expect(response).to have_http_status(:internal_server_error)
        expect(json_response[:messages]).to eq [
          'hits: [ invalid value for "total", total cannot be nil. ]'
        ]
      end
    end
  end

  def query(q: nil, index_strategy: nil, search_strategy: nil, book_id: index_id)
    "q=#{q}&index_strategy=#{index_strategy}&search_strategy=#{search_strategy}&books=#{book_id}"
  end
end

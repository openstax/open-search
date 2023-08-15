require 'rails_helper'
require 'vcr_helper'

# In this test, the book content is drawn from the file fixture (to limit the
# book to 1 page) & the page content is drawn from cnx archive and recorded thru
# vcr
#
# OpenSearch must be running for this test to succeed
# e.g  docker run
#          -p 9200:9200 -p 9300:9300
#          -e "discovery.type=single-node"
#          opensearchproject/opensearch:2.7
RSpec.describe Books::Index, vcr: VCR_OPTS do
  let(:pipeline) { '20230620.181811' }
  let(:book_id_at_version) { '4fd99458-6fdf-49bc-8688-a6dc17a1268d@f1ce9ea' }
  let(:book_version_id) { "#{pipeline}/#{book_id_at_version}" }
  let(:test_book_json) { JSON.parse(file_fixture('mini.json').read) }

  subject(:index) { described_class.new(book_version_id: book_version_id) }

  def delete_index
    if OxOpenSearchClient.instance.indices.exists? index: index.name
      OxOpenSearchClient.instance.indices.delete index: index.name
    end
  end

  before { delete_index }
  after { delete_index }

  describe "#create" do
    it 'creates the index' do
      index.create
      expect(OxOpenSearchClient.instance.indices.exists?(index: index.name)).to be_truthy
    end
  end

  describe '#populate' do
    let(:test_book_url) {
      "https://openstax.org/apps/archive/#{pipeline}/contents/#{book_id_at_version}"
    }
    let(:test_page_url) {
      "#{test_book_url.gsub('.json','')}:ccc4ed14-6c87-408b-9934-7a0d279d853a"
    }
    let(:test_book_json) { JSON.parse(file_fixture('rap_mini.json').read) }

    before do
      allow(OpenStax::Cnx::V1).to receive(:fetch).with(test_book_url).and_return(test_book_json)
      allow(OpenStax::Cnx::V1).to receive(:fetch).with(test_page_url).and_call_original
    end

    it 'populates the index' do
      index.create
      index.populate
      sleep 1 if VCR.current_cassette.try!(:recording?)  # wait for OpenSearch to finish

      expect(OxOpenSearchClient.instance.count(index: index.name, q: "arm")["count"]).to eq 1
    end

  end

  describe "#hide_unwanted_items" do
    # This page from Physics book contains .os-teacher elements that should not be indexed
    # See https://github.com/openstax/unified/issues/1559
    let(:pipeline) { '20230620.181811' }
    let(:physics_id_at_version) { 'cce64fde-f448-43b8-ae88-27705cceb0da@72af53d' }
    let(:physics_version_id) { "#{pipeline}/#{physics_id_at_version}" }
    let(:physics_json) { JSON.parse(file_fixture('mini_physics.json').read) }
    let(:physics_url) { "https://openstax.org/apps/archive/#{pipeline}/contents/#{physics_id_at_version}" }
    let(:physics_page_url) { "#{physics_url}:5f0710fe-1028-4ac4-b8fd-b0a6c792c642" }

    subject(:index) { described_class.new(book_version_id: physics_version_id) }

    before do
      allow(OpenStax::Cnx::V1).to receive(:fetch).with(physics_url).and_return(physics_json)
      allow(OpenStax::Cnx::V1).to receive(:fetch).with(physics_page_url).and_call_original
    end

    it 'does not include unwanted elements in index' do
      index.create
      index.populate
      sleep 1 if VCR.current_cassette.try!(:recording?)  # wait for OpenSearch to finish

      expect(OxOpenSearchClient.instance.count(index: index.name)["count"]).to eq 50
    end
  end

  describe "#delete" do
    it 'deletes the index' do
      index.create
      expect(OxOpenSearchClient.instance.indices.exists?(index: index.name)).to be_truthy
      index.delete
      expect(OxOpenSearchClient.instance.indices.exists?(index: index.name)).to be_falsey
    end
  end

  describe "#name" do
    it 'derives the index name' do
      expect(index.name).to eq '20230620.181811__4fd99458-6fdf-49bc-8688-a6dc17a1268d@f1ce9ea_i1'
    end
  end
end

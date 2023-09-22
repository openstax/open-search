require 'rails_helper'
require 'vcr_helper'

RSpec.describe IndexInfo, vcr: VCR_OPTS do
  let(:pipeline) { '20230620.181811' }
  let(:book_id_at_version) { '4fd99458-6fdf-49bc-8688-a6dc17a1268d@f1ce9ea' }
  let(:index_id) { "#{pipeline}/#{book_id_at_version}" }
  let(:indexing_strategy) { Books::SearchStrategies::Factory::INDEXING_CLASSES.first }
  let(:index) { Books::Index.new(index_id: index_id, indexing_strategy: indexing_strategy) }
  let(:indexing_strategy_name) { "I1" }
  let(:book_index_name) { "#{pipeline}__#{book_id_at_version}_#{indexing_strategy_name}".downcase }

  before(:each) do
    do_not_record_or_playback do
      if !index.exists?
        index.create
        index.populate
      end
    end
  end

  subject(:info_service) { described_class.new }

  describe "#call" do
    let(:iso8601_regex) {
      /^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]+)?(Z)?$/
    }

    context "OpenSearch and dynamodb records both exist" do
      it "gets the info" do
        TempAwsEnv.make do |env|
          env.create_dynamodb_table
          BookIndexState.create(index_id: index_id, indexing_strategy_name: indexing_strategy_name)

          info = info_service.call

          book_info = info[:book_indexes].detect{|index| index[:id] == book_index_name}
          expect(book_info[:state]).to eq 'create pending'
          expect(book_info[:created_at]).to match iso8601_regex
        end
      end
    end

    context "OpenSearch exists but not a dynamodb" do
      it "gets the info" do
        TempAwsEnv.make do |env|
          env.create_dynamodb_table

          info = info_service.call

          book_info = info[:book_indexes].detect{|index| index[:id] == book_index_name}
          expect(book_info[:state]).to eq 'not found'
          expect(book_info[:created_at]).to match iso8601_regex
        end
      end
    end
  end
end

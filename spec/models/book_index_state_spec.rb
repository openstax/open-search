require 'rails_helper'
require 'vcr_helper'

# A BookIndexState model is the ORM to the AWS dynamo db.  This table records
# book indexing jobs enqueuing, starting, and finishing.
RSpec.describe BookIndexState, vcr: VCR_OPTS do
  let(:pipeline) { '20230620.181811' }
  let(:book_id_at_version) { '4fd99458-6fdf-49bc-8688-a6dc17a1268d@f1ce9ea' }
  let(:index_id) { "#{pipeline}/#{book_id_at_version}" }
  let(:indexing_strategy_name) { 'I1' }

  subject(:book_index_state) { described_class }

  describe ".create" do
    it 'creates a document item in the dynamo db table with correct status' do
      TempAwsEnv.make do |env|
        env.create_dynamodb_table

        book = book_index_state.create(index_id: index_id, indexing_strategy_name: indexing_strategy_name)
        created_book_arel = BookIndexState.where(index_id: index_id, indexing_strategy_name: indexing_strategy_name)
        expect(created_book_arel.count).to eq 1

        book_status_log = book.status_log
        expect(book_status_log.count).to eq 1
        expect(book_status_log.first.action).to eq BookIndexState::StatusLog::ACTION_CREATE
      end
    end
  end

  describe ".live_book_indexings" do
    let(:index_id1) { 'book@1' }
    let(:index_id2) { 'book@2' }
    let(:index_id3) { 'book@3' }
    let(:index_id4) { 'book@4' }

    def init_test
      book_index_state.new(state: BookIndexState::STATE_CREATE_PENDING,
                           index_id: index_id1,
                           indexing_strategy_name: indexing_strategy_name,
                           message: 'message 1').save!
      book_index_state.new(state: BookIndexState::STATE_DELETE_PENDING,
                           index_id: index_id2,
                           indexing_strategy_name: indexing_strategy_name,
                           message: 'message 2').save!
      book_index_state.new(state: BookIndexState::STATE_CREATED,
                           index_id: index_id3,
                           indexing_strategy_name: indexing_strategy_name,
                           message: 'message 3').save!
      book_index_state.new(state: BookIndexState::STATE_HTTP_ERROR,
                           index_id: index_id4,
                           indexing_strategy_name: indexing_strategy_name,
                           message: 'message 4').save!
    end

    it 'finds only live documents, not the deleting ones' do
      TempAwsEnv.make do |env|
        env.create_dynamodb_table
        init_test

        expect(BookIndexState.all.count).to eq 4
        expect(BookIndexState.live.count).to eq 3
      end
    end
  end

  describe "#mark_queued_for_deletion" do
    let(:live_indexing) do
      book_index_state.create(index_id: index_id, indexing_strategy_name: indexing_strategy_name)
    end

    it 'updates the document to be deleted' do
      TempAwsEnv.make do |env|
        env.create_dynamodb_table

        expect(live_indexing.state).to eq BookIndexState::STATE_CREATE_PENDING
        live_indexing.mark_queued_for_deletion
        expect(live_indexing.state).to eq BookIndexState::STATE_DELETE_PENDING
      end
    end
  end

  describe "#mark_created" do
    let(:live_indexing) do
      book_index_state.create(index_id: index_id, indexing_strategy_name: indexing_strategy_name)
    end

    it 'updates the document to created and updates the status log' do
      TempAwsEnv.make do |env|
        env.create_dynamodb_table

        expect(live_indexing.state).to eq BookIndexState::STATE_CREATE_PENDING
        live_indexing.mark_created
        expect(live_indexing.state).to eq BookIndexState::STATE_CREATED
        expect(live_indexing.status_log.last.action).to eq BookIndexState::StatusLog::ACTION_CREATED
      end
    end
  end
end

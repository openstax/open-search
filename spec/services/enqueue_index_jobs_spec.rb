require 'rails_helper'

RSpec.describe EnqueueIndexJobs do
  let(:indexing_strategy_name) { 'I1' }
  let(:book_ids) {%w(foo@1 foo@2)}
  let(:book1_to_index) { double(index_id: 'foo@1', in_demand: true, indexing_strategy_name: 'i1') }
  let(:book2_to_index) { double(index_id: 'foo@2', in_demand: true, indexing_strategy_name: 'i1') }

  subject(:enqueue_index_job) { described_class.new }

  context "new book listings" do
    let(:book1_to_index) { double(index_id: 'foo@1', in_demand: true, indexing_strategy_name: 'i1') }
    let(:book2_to_index) { double(index_id: 'foo@2', in_demand: true, indexing_strategy_name: 'i1') }

    before do
      allow_any_instance_of(Rex::Releases).to receive(:book_ids).and_return(book_ids)
      allow_any_instance_of(Rex::Releases).to receive(:load_releases)
      allow_any_instance_of(TodoJobsQueue).to receive(:count).and_return(2)
      allow(BookIndexState).to receive(:live).and_return([book1_to_index, book2_to_index])
    end

    describe "#call" do
      it 'sends expected messages to the BookIndexState, TodoJobsQueue, and asg objects' do
        expect(BookIndexState).to receive(:create).exactly(6).times

        todo_jobs_receive_count = 0
        allow_any_instance_of(TodoJobsQueue).to receive(:write) { todo_jobs_receive_count += 1 }

        enqueue_index_job.call

        expect(todo_jobs_receive_count).to eq 6
      end
    end
  end

  context "enqueued book listings not existing in rex releases" do
    let(:released_book_ids) {%w(foo@1)}
    let(:book1_elt_index)   { double(index_id: 'foo@1', in_demand: true, indexing_strategy_name: 'I1') }
    let(:book1_bk_index)    { double(index_id: 'foo@1', in_demand: true, indexing_strategy_name: 'I2') }
    let(:book1_pg_index)    { double(index_id: 'foo@1', in_demand: true, indexing_strategy_name: 'I3') }
    let(:now_inactive_book) { double(index_id: 'foo@2', in_demand: false, indexing_strategy_name: 'I1') }

    before do
      allow_any_instance_of(Rex::Releases).to receive(:book_ids).and_return(released_book_ids)
      allow_any_instance_of(Rex::Releases).to receive(:load_releases)
      allow_any_instance_of(TodoJobsQueue).to receive(:count).and_return(2)
      allow(BookIndexState).to receive(:live).and_return([book1_elt_index, now_inactive_book, book1_bk_index, book1_pg_index])
    end

    describe "#call" do
      it 'enqueues one delete job: one book state (foo@1) is already indexed & one (foo@2) is now inactive' do
        expect_any_instance_of(TodoJobsQueue).to receive(:write).with(instance_of(DeleteIndexJob)).once
        expect(book1_elt_index).to receive(:in_demand=).with(true).once
        expect(book1_bk_index).to receive(:in_demand=).with(true).once
        expect(book1_pg_index).to receive(:in_demand=).with(true).once
        expect(now_inactive_book).to receive(:mark_queued_for_deletion).once

        enqueue_index_job.call
      end
    end
  end
end

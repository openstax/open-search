class CreateIndexJob < BaseIndexJob
  def cleanup_when_done
    book_index_state = find_associated_book_index_state
    book_index_state&.mark_created
  end

  def as_json(*)
    {
      type: type,
      index_id: index_id,
      indexing_strategy_name: indexing_strategy_name
    }
  end

  private

  def _call
    # We call index.create instead of index.recreate here because this job
    # has to be idempotent due to the possibility of duplicate message delivery from SQS
    # If the index already exists, the job will fail and this worker will remove it from the queue,
    # but the worker that managed to create the index first will be able to continue working on it
    index.create
    index.populate
  end
end

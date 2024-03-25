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
    # If the index already exists, we simply attempt to recreate all the records
    index.create if index.not_exists?
    index.populate
  end
end

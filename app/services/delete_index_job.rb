class DeleteIndexJob < BaseIndexJob
  def cleanup_when_done
    remove_associated_book_index_state
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
    index.delete
  end
end

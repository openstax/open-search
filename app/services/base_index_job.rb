class BaseIndexJob
  attr_reader :indexing_strategy_name,
              :index_id,
              :type

  def self.build_object(params:, cleanup_after_call: nil)
    new(index_id:               params[:index_id],
        indexing_strategy_name: params[:indexing_strategy_name],
        cleanup_after_call:     cleanup_after_call)
  end

  def initialize(index_id: nil,
                 indexing_strategy_name: nil,
                 cleanup_after_call: nil)
    @cleanup_after_call = cleanup_after_call

    @type = self.class.to_s
    @index_id = index_id
    @indexing_strategy_name = indexing_strategy_name
  end

  def call
    _call
  ensure #it should always remove the job from the queue
    @cleanup_after_call.try(:call)
  end

  def cleanup_when_done
  end

  def to_hash
    JSON.parse(to_json).with_indifferent_access
  end

  def remove_associated_book_index_state
    book_index_state = find_associated_book_index_state
    book_index_state&.destroy!
  end

  def inspect
    # The book index state is not available on the worker, but is on the
    # manager nodes.
    index_state = find_associated_book_index_state rescue nil
    to_hash.merge((index_state || {}).to_hash)
  end

  def find_associated_book_index_state
    BookIndexState.where(index_id: index_id, indexing_strategy_name: indexing_strategy_name).first
  end

  def index
    @index ||= Books::Index.new(
      index_id: @index_id,
      indexing_strategy: Books::SearchStrategies::Factory::NAMES_TO_INDEXING_CLASSES[indexing_strategy_name.downcase]
    )
  end

  def cleanup_after_call
    @cleanup_after_call.try(:call)
  end

  private

  def _call
    raise "Implement _call in any derived class!"
  end
end

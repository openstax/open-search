# Indexes a book version thru the SQS queuing system
class EnqueueIndexJobs
  prefix_logger "EnqueueIndexJobs"

  def initialize
    @todo_jobs_queue = TodoJobsQueue.new
    @new_create_index_jobs = 0
    @new_delete_index_jobs = 0
  end

  def call
    log_info { "Starting..." }

    BOOK_INDEXING_STRATEGY_NAMES.each do |strategy_name|
      released_book_ids.each do |book_id|
        existing_book_indexing = find_indexing(book_id, strategy_name)

        if existing_book_indexing
          existing_book_indexing.in_demand = true
        else
          enqueue_create_index_job(book_id, strategy_name)
        end
      end
    end

    REX_RELEASE_INDEXING_STRATEGY_NAMES.each do |strategy_name|
      rex_release_ids.each do |rex_release_id|
        existing_release_indexing = find_indexing(rex_release_id, strategy_name)

        if existing_release_indexing
          existing_release_indexing.in_demand = true
        else
          enqueue_create_index_job(rex_release_id, strategy_name)
        end
      end
    end

    unneeded_indexings = index_states.reject(&:in_demand)

    unneeded_indexings.each do |unneeded_indexing|
      enqueue_delete_index_job(unneeded_indexing)
    end

    log_info { "Completed: #{stats}" }

    stats
  end

  private

  def stats
    {
      num_delete_index_jobs: @new_delete_index_jobs,
      num_create_index_jobs: @new_create_index_jobs
    }
  end

  def index_states
    @index_states ||= BookIndexState.live.to_a
  end

  def find_indexing(index_id, indexing_strategy_name)
    @fast_lookup_hash ||= index_states.each_with_object({}) do |indexing, hash|
      hash["#{indexing.index_id}#{indexing.indexing_strategy_name}"] = indexing
    end

    @fast_lookup_hash["#{index_id}#{indexing_strategy_name}"]
  end

  def enqueue_create_index_job(index_id, indexing_strategy_name)
    job = CreateIndexJob.new(index_id: index_id, indexing_strategy_name: indexing_strategy_name)
    @todo_jobs_queue.write(job)

    BookIndexState.create(index_id: index_id, indexing_strategy_name: indexing_strategy_name)

    @new_create_index_jobs += 1

    log_info { "Enqueued creation for '#{index_id} #{indexing_strategy_name}'" }
  end

  def enqueue_delete_index_job(book_indexing)
    job = DeleteIndexJob.new(index_id: book_indexing.index_id, indexing_strategy_name: book_indexing.indexing_strategy_name)
    @todo_jobs_queue.write(job)

    book_indexing.mark_queued_for_deletion

    @new_delete_index_jobs += 1

    log_info { "Enqueued deletion for '#{book_indexing.index_id} #{book_indexing.indexing_strategy_name}'" }
  end

  def released_book_ids
    @released_book_ids ||= Rex::Releases.new.book_ids
  end

  def rex_release_ids
    @rex_release_ids ||= Rex::Releases.new.release_ids
  end

  def new_jobs
    @new_delete_index_jobs + @new_create_index_jobs
  end

end

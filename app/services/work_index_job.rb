# Work an Index job from the SQS queue
#
# There are 2 types of work to do from this queue:
# (1) CreateIndexJob - will (re)build the search index for this book version and indexing version
# (2) DeleteIndexJob - will delete the search indexed for this unneeded book
class WorkIndexJob
  def initialize
    @todo_jobs_queue = TodoJobsQueue.new
    @done_jobs_queue = DoneJobsQueue.new
    @stats = { DeleteIndexJob => 0, CreateIndexJob => 0 }
    @out_of_work = false
  end

  def fuzzy_check_out_of_work?
    @out_of_work
  end

  def call
    job = @todo_jobs_queue.read
    if job.nil?
      @out_of_work = true
      return job_stats
    else
      @out_of_work = false
    end

    begin
      validate_indexing_version(job)

      starting = Time.now
      es_stats = job.call
      time_took = Time.at(Time.now - starting).utc.strftime("%H:%M:%S")

      Rails.logger.info("OpenSearch: WorkIndexJob job #{job.class.to_s} took #{time_took} time. json #{job.to_json}")

      enqueue_done_job(job: job,
                       status: DoneIndexJob::Results::STATUS_SUCCESSFUL,
                       es_stats: es_stats,
                       time_took: time_took)

      job.when_completed
    rescue InvalidIndexingVersion
      enqueue_done_job(job: job,
                       status: DoneIndexJob::Results::STATUS_INVALID_INDEXING_VERSION)
    rescue => ex
      enqueue_done_job(job: job,
                       status: DoneIndexJob::Results::STATUS_OTHER_ERROR,
                       message: ex.message)
    end

    job_stats
  end

  private

  class InvalidIndexingVersion < StandardError; end

  def validate_indexing_version(job)
    unless ACTIVE_INDEXING_VERSIONS.include?(job.indexing_version)
      raise InvalidIndexingVersion
    end
  end

  def enqueue_done_job(job:, status:, message: nil, time_took: nil, es_stats: nil)
    done_job_results = DoneIndexJob::Results.new(status: status,
                                                message: message,
                                                time_took: time_took,
                                                es_stats: es_stats)

    done_job = DoneIndexJob.new( results: done_job_results,
                            book_version_id: job.book_version_id,
                            indexing_version:job.indexing_version)

    enqueue_to_done(done_job)

    record_job_stat(job)
  end

  def enqueue_to_done(job)
    @done_jobs_queue.write(job)
  end

  def record_job_stat(job)
    @stats[job.class] += 1
  end

  def job_stats
    {
      num_index_jobs_processed: @stats[CreateIndexJob],
      num_delete_index_jobs_processed: @stats[DeleteIndexJob]
    }
  end

  def worker_asg_name
    Rails.application.secrets.search_worker_asg_name
  end
end
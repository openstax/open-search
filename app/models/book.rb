class Book < OpenStax::Cnx::V1::Book

  # Modifies OpenStax::Cnx::V1::Book to be aware of RAP pipelines.  The ID of a
  # legacy archive books is still "uuid@version".  The ID of a RAP book is
  # "pipeline/uuid@version".  These IDs flow elsewhere to index names, etc.

  RAP_URL_WITHOUT_PIPELINE = "https://openstax.org/apps/archive"
  LEGACY_ARCHIVE_URL = "https://openstax.org"

  attr_reader :pipeline, :uuid, :version

  def self.from_id(id)
    uuid_at_version, pipeline = id.split('/').reverse
    uuid, version = uuid_at_version.split('@')
    new(pipeline: pipeline, uuid: uuid, version: version)
  end

  def initialize(pipeline:, uuid:, version:)
    @pipeline = pipeline
    @uuid = uuid
    @version = version

    id = "#{uuid}@#{version}"
    id = "#{pipeline}/#{id}" if pipeline.present?

    super(id: id)
  end

  def rap?
    pipeline.present?
  end

  def url
    @url ||= canonical_url
  end

  def canonical_url
    # We use `File.join` instead of `Addressable::URI.join` because the latter strips
    # path components off of the first argument.
    @canonical_url ||= File.join(archive_url, '/contents/', "#{uuid}@#{version}").to_s
  end

  def archive_url
    rap? ? "#{RAP_URL_WITHOUT_PIPELINE}/#{pipeline}" : LEGACY_ARCHIVE_URL
  end

end

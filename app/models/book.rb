class Book < OpenStax::Cnx::V1::Book

  RAP_URL_WITHOUT_PIPELINE = "https://openstax.org/apps/archive"
  LEGACY_ARCHIVE_URL = "https://openstax.org/contents"

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

  def archive_url
    pipeline.blank? ? LEGACY_ARCHIVE_URL : "#{RAP_URL_WITHOUT_PIPELINE}/#{pipeline}"
  end

  def with_its_archive_url
    OpenStax::Cnx::V1.with_archive_url(archive_url) do
      yield
    end
  end
end

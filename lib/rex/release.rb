require 'json'

module Rex
  class Release
    attr_reader :id, :data, :config

    def self.from_id(release_id, bucket = nil)
      release_folder = "rex/releases/#{release_id}"
      bucket ||= Rex::Releases.new.bucket
      release_file = bucket.file(key: "#{release_folder}/rex/release.json")

      raise ReleaseNotFound, release_id unless release_file.exists?

      config_file = bucket.file(key: "#{release_folder}/rex/config.json")

      new(
        id: release_id,
        data: release_file.to_hash,
        config: Config.new(data: config_file.to_hash)
      )
    end

    def initialize(id:, data:, config:)
      @id = id
      @data = data.with_indifferent_access
      @config = config
    end

    def books
      @books ||= @data["books"].map do |uuid, info|
        next if info['retired']

        pipeline = config.pipeline
        pipeline = info['archiveOverride'].delete_prefix('/apps/archive/') if info.has_key?(:archiveOverride)

        Book.new(pipeline: pipeline, uuid: uuid, version: info["defaultVersion"])
      end.compact
    end

    def clear_book_cache
      @books = nil
    end
  end
end

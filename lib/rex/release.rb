require 'json'

module Rex
  class Release
    attr_reader :id, :data, :config

    def initialize(id:, data:, config:)
      @id = id
      @data = data.with_indifferent_access
      @config = config
    end

    def books
      @books ||= @data["books"].map do |uuid, info|
        pipeline = config.pipeline
        pipeline = info['archiveOverride'].delete_prefix('/apps/archive/') if info.has_key?(:archiveOverride)

        Book.new(pipeline: pipeline, uuid: uuid, version: info["defaultVersion"])
      end
    end
  end
end

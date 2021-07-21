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
        Book.new(pipeline: config.pipeline, uuid: uuid, version: info["defaultVersion"])
      end
    end
  end
end

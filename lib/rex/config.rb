require 'json'

module Rex
  class Config
    attr_reader :data

    def initialize(data:)
      @data = data
    end

    def pipeline
      data['REACT_APP_ARCHIVE_URL']&.match(/\/apps\/archive\/(.*)/).try(:[], 1)
    end
  end
end

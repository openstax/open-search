module OpenStax::Cnx::V1

  # The cnx-ruby gem uses `Addressable::URI.join` which has the unwanted side effect of scrubbing
  # the path out of the first argument.  We want that path (e.g. `/apps/archive/#{pipeline}`) so
  # here we use `File.join` instead, which concatenates and takes care of extra or missing
  # slashes between arguments.
  #
  # The path may also contain the pipeline identifier, which must be removed because we have
  # already included it in the archive_url_base
  def self.archive_url_for(path)
    if path.match?(/\//)
      path = path.gsub(/.*\//, '')
      path += ".json"
    end
    File.join(configuration.archive_url_base, '/contents/', path).to_s
  end


  class Page
    def url
      @url ||= begin
        if book.pipeline.present?
          # RAP doesn't use the "@23" version indicator at the end of page URLs
          # also needs .json extension at end and removed from book url base
          "#{url_for(id.gsub(/@[\d\.]+$/,'')).gsub('.json', '')}.json"
        else
          url_for(id)
        end
      end
    end
  end

end

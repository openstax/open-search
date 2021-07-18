module OpenStax::Cnx::V1

  class << self

    # RAP requires .json extensions on requests; on legacy archive, .json extensions are optional
    # so here we require them and it will work for both
    alias_method :original_fetch, :fetch
    def fetch(url)
      original_fetch("#{url}.json")
    end

  end

  class Page
    def id_without_version
      id.gsub(/@[\d\.]+$/,'')
    end

    def url
      # RAP doesn't use the "@23" version indicator at the end of page URLs
      @url ||= book.rap? ? url_for(id_without_version) : url_for(id)
    end
  end

end

module OpenStax::Cnx::V1

  class << self

    # RAP requires .json extensions on requests; on legacy archive, .json extensions are optional
    # so here we require them and it will work for both.  Also, Legacy sometimes gets overwhelmed
    # by the volume of requests, so we retry a number of times for 503 status responses.

    alias_method :original_fetch, :fetch

    def fetch(url)
      max_attempts = 5
      attempt_number = 0
      url = "#{url}.json"

      begin
        attempt_number += 1
        original_fetch(url).tap do
          Rails.logger.info("Fetched #{url} on a retry.") if attempt_number > 1
        end
      rescue OpenStax::HTTPError, Errno::ECONNRESET => exception
        raise unless exception.is_a?(Errno::ECONNRESET) || exception.message.match?(/503/)

        if attempt_number >= max_attempts
          Rails.logger.error("Fetching #{url} failed, tried #{max_attempts} times.")
          raise
        else
          Rails.logger.warn("Fetching #{url} failed, sleeping and trying again.")
          # exponential backoff, with 10 extra seconds for CloudFront 503 cache expiration
          sleep(2 ** attempt_number + 10) unless Rails.env.test?
          retry
        end
      end
    end

  end

  class Page
    def id_without_version
      id.gsub(/@[\d\.]*$/,'')
    end

    def url
      # RAP doesn't use the "@23" version indicator at the end of page URLs
      @url ||= book.rap? ? url_for(id_without_version) : url_for(id)
    end
  end

end

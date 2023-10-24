module Rex
  class Releases
    include Enumerable
    extend Forwardable

    attr_reader :releases, :bucket

    def_delegators :@releases, :each, :find, :map, :size, :count, :first, :last

    def initialize
      @bucket = Bucket.new(
        name: Rails.application.secrets.rex_release_bucket[:name],
        region: Rails.application.secrets.rex_release_bucket[:region]
      )
      @releases = load_releases
    end

    def release_ids
      map(&:id)
    end

    def book_ids
      # return rap books first to try to priotize their indexing first
      map(&:books).flatten.sort_by{|book| book.rap? ? 0 : 1}.map(&:id).uniq
    end

    def find_by_id(id)
      find { |release| release.id == id }
    end

    protected

    def load_releases
      load_release_folder(folder_prefix: 'rex/releases/')
    end

    def load_release_folder(folder_prefix:)
      release_folders = bucket.folders_under(folder: folder_prefix)
      return [] if release_folders.empty?

      release_folders.map do |release_folder|
        release_id = release_folder.match(/rex\/releases\/(.*)\//)[1]
        begin
          Release.from_id(release_id, bucket)
        rescue ReleaseNotFound
          # This is not the release folder, keep searching deeper
          load_release_folder(folder_prefix: release_folder)
        end
      end.flatten
    end
  end
end

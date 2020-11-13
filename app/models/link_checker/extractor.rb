# frozen_string_literal: true

module LinkChecker
  Link = Struct.new(:title, :url, :source_title, :source_url, :response)

  class Extractor
    def initialize(markdown_text, source_title, source_url)
      @markdown_text = markdown_text
      @source_title = source_title
      @source_url = source_url
    end

    def extract
      links = @markdown_text.scan(/\[(.*?)\]\((.+?)\)/)&.map do |match|
        title, url = match[0], match[1]
        if url.match?(%r{^/})
          uri = URI(@source_url)
          uri.path = ""
          url = uri.to_s + url
        end
        Link.new(title, url, @source_title, @source_url)
      end

      links.select { |link| URI.regexp.match(link.url) }
    end
  end
end

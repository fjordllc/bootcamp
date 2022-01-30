# frozen_string_literal: true

module LinkChecker
  Link = Struct.new(:title, :url, :source_title, :source_url, :response)

  class Extractor
    class << self
      def extract_all_links(documents)
        documents.flat_map do |document|
          new(
            document.body,
            document.title,
            "https://bootcamp.fjord.jp#{document.path}"
          )
        end
      end
    end

    def initialize(markdown_text, source_title, source_url)
      @markdown_text = markdown_text
      @source_title = source_title
      @source_url = source_url
    end

    def extract_links
      links = @markdown_text.scan(/\[(.*?)\]\((.+?)\)/)&.map do |match|
        title = match[0].strip
        url = match[1].strip
        if url.match?(%r{^/})
          uri = URI(@source_url)
          uri.path = ''
          url = uri.to_s + url
        end
        Link.new(title, url, @source_title, @source_url)
      end

      links.select { |link| URI::DEFAULT_PARSER.make_regexp.match(link.url) }
    end
  end
end

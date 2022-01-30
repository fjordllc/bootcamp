# frozen_string_literal: true

module LinkChecker
  Link = Struct.new(:title, :url, :source_title, :source_url, :response)

  class Extractor
    MARKDOWN_LINK_REGEXP = %r{\[(.*?)\]\((#{URI::DEFAULT_PARSER.make_regexp}|/.*?)\)}.freeze

    class << self
      def extract_all_links(documents)
        documents.flat_map { |document| new(document).extract_links }
      end
    end

    def initialize(document)
      @document = document
    end

    def extract_links
      links = @document.body.scan(MARKDOWN_LINK_REGEXP).map do |title, url_or_path|
        title = title.strip
        url_or_path = url_or_path.strip
        url_or_path = "https://bootcamp.fjord.jp#{url_or_path}" if url_or_path.match?(%r{^/})

        Link.new(title, url_or_path, @document.title, "https://bootcamp.fjord.jp#{@document.path}")
      end

      links.select { |link| URI::DEFAULT_PARSER.make_regexp.match(link.url) }
    end
  end
end

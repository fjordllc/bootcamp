# frozen_string_literal: true

module LinkChecker
  Link = Struct.new(:title, :url, :source_title, :source_url, :response)

  class Extractor
    class << self
      def extract_all_links(documents)
        documents.flat_map { |document| new(document).extract_links }
      end
    end

    def initialize(document)
      @document = document
    end

    def extract_links
      links = @document.body.scan(/\[(.*?)\]\((.+?)\)/)&.map do |match|
        title = match[0].strip
        url = match[1].strip
        url = "https://bootcamp.fjord.jp#{url}" if url.match?(%r{^/})

        Link.new(title, url, @document.title, "https://bootcamp.fjord.jp#{@document.path}")
      end

      links.select { |link| URI::DEFAULT_PARSER.make_regexp.match(link.url) }
    end
  end
end

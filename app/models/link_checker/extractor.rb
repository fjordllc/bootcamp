# frozen_string_literal: true

module LinkChecker
  module Extractor
    MARKDOWN_LINK_REGEXP = %r{\[(.*?)\]\((#{URI::DEFAULT_PARSER.make_regexp}|/.*?)\)}.freeze

    module_function

    def extract_links_from_multi(documents)
      documents.flat_map { |document| extract_links_from_a(document) }
    end

    def extract_links_from_a(document)
      document.body.scan(MARKDOWN_LINK_REGEXP).map do |title, url_or_path|
        title = title.strip
        url_or_path = url_or_path.strip
        url_or_path = "https://bootcamp.fjord.jp#{url_or_path}" if url_or_path.match?(%r{^/})

        Link.new(title, url_or_path, document.title, "https://bootcamp.fjord.jp#{document.path}")
      end
    end
  end
end

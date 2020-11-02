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
      @markdown_text.scan(/\[(.*)\]\((.+)\)/)&.map do |match|
        Link.new(match[0], match[1], @source_title, @source_url)
      end
    end
  end
end

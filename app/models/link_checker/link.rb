# frozen_string_literal: true

module LinkChecker
  Link = Struct.new(:title, :url, :source_title, :source_url, :response) do
    def to_s
      "- <#{url} | #{title}> in: <#{source_url} | #{source_title}>"
    end

    def <=>(other)
      (source_url <=> other.source_url).nonzero? || url <=> other.url
    end
  end
end

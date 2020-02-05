require "open-uri"
require "nokogiri"

class GithubGrass
  SELECTOR = "svg.js-calendar-graph-svg"

  def initialize(name)
    @name = name
  end

  def fetch
    extract_svg open(github_url(@name)) { |f| f.read }
  rescue OpenURI::HTTPError
    ""
  end

  def extract_svg(html)
     Nokogiri::HTML(html).css(SELECTOR).to_s
  end

  def github_url(name)
    "https://github.com/#{name}"
  end
end

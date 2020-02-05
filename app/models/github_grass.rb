require "open-uri"
require "nokogiri"

class GithubGrass
  attr_reader :cache_key

  def initialize(user)
    @user_github_url = "https://github.com/#{user.github_account}"
    @cache_key = "github_grass/" + @user.id.to_s
  end

  def take_svg
    charset = nil
    html = open(@user_github_url, "r:utf-8") do |f|
      charset = f.charset
      f.read
    end
    github_page = Nokogiri::HTML.parse(html, nil, charset)
    @github_grass = github_page.css("svg.js-calendar-graph-svg")[0]
  end
end

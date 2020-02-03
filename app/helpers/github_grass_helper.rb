# frozen_string_literal: true

require "open-uri"
require "nokogiri"

module GithubGrassHelper
  def github_grass_filepath(user)
    if File.exist?(filepath + filename(user)) &&
       Time.now - File.mtime(filepath + filename(user)) < 86400
    else
      arrange_svg(set_github_grass(user))
      output_svg(user, @github_grass)
    end
    "/images/users/github_grass/" + filename(user)
  end

  def arrange_svg(grass)
    arrange_wday_label(grass)
    arrange_month_label(grass)
    visualize_svg(grass)
  end

  def output_svg(user, grass)
    File.open(filepath + filename(user), "wb") { |svg| svg << grass }
  end

  private
    def arrange_wday_label(grass)
      count = 0
      wdays = ["日", "月", "火", "水", "木", "金", "土"]
      grass.css("text.wday").map do |wday|
        wday[:style] = ""
        wday[:dy] = 12 + (15 * count)
        wday.children = wdays[count]
        count += 1
      end
    end

    def arrange_month_label(grass)
      months = { Jan: "1", Feb: "2", Mar: "3", Apr: "4",
                May: "5", Jun: "6", Jul: "7", Aug: "8",
                Sep: "9", Oct: "10", Nov: "11", Dec: "12" }
      grass.css("text.month").map do |month|
        month.children = months[month.children.text.to_sym]
      end
    end

    def visualize_svg(grass)
      grass[:xmlns] = "http://www.w3.org/2000/svg"
    end

    def filepath
      "#{Rails.root}/public/images/users/github_grass/"
    end

    def filename(user)
      user.login_name + ".svg"
    end

    def set_github_grass(user)
      charset = nil
      html = open("https://github.com/#{user.github_account}", "r:utf-8") do |f|
        charset = f.charset
        f.read
      end
      github_page = Nokogiri::HTML.parse(html, nil, charset)
      @github_grass = github_page.css("svg.js-calendar-graph-svg")[0]
    end
end

# frozen_string_literal: true

module GithubGrassHelper
  def github_grass(user)
    github_grass = GithubGrass.new(user)
    Rails.cache.fetch(github_grass.chash_key, expired_in: 24.hours) do
      raw_svg = github_grass.take_svg
      target_svg = GrassArrangement.new(raw_svg)
      target_svg.arrange_wday_label
      target_svg.arrange_month_label
    end
  end
end

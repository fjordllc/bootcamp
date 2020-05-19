# frozen_string_literal: true

module GithubGrassHelper
  def github_grass(name)
    GithubGrass.new(name).fetch.html_safe
  end
end

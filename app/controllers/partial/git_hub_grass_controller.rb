# frozen_string_literal: true

class Partial::GitHubGrassController < PartialController
  def show
    render plain: GithubGrass.new(params[:name]).fetch.html_safe # rubocop:disable Rails/OutputSafety
  end
end

class API::GithubContributionsController < API::BaseController
  def show
    @table = GithubContribution.new(params[:id]).generate_table
  end
end

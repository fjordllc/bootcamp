# frozen_string_literal: true

class Talks::ActionUncompletedController < ApplicationController
  before_action :require_admin_login

  def index
    @talks = Talk.joins(:user)
                 .includes(user: [{ avatar_attachment: :blob }, :discord_profile])
                 .action_uncompleted
                 .order(updated_at: :desc, id: :asc)

    if params[:search_word]
      search_user = SearchUser.new(search_word: params[:search_word], require_retire_user: true)
      @search_word = search_user.search_word
    end

    if @search_word
      searched_users = search_user.search
      @searched_talks = @talks.merge(searched_users).page(params[:page])
    else
      @talks = @talks.page(params[:page])
    end
  end
end

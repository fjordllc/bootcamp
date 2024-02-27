# frozen_string_literal: true

class Talks::ActionUncompletedController < ApplicationController
  before_action :require_admin_login

  def index
    @talks = Talk.joins(:user)
                 .includes(user: [{ avatar_attachment: :blob }, :discord_profile])
                 .action_uncompleted
                 .order(updated_at: :desc, id: :asc)
    if params[:search_word]
      @searched_talks = @talks.merge(
        User.search_by_keywords({ word: params[:search_word] })
            .unscope(where: :retired_on)
      ).page(params[:page])
    else
      @talks = @talks.page(params[:page])
    end
  end
end

# frozen_string_literal: true

class API::Talks::ActionUncompletedController < API::BaseController
  PAGER_NUMBER = 20

  def index
    @talks = Talk.joins(:user)
                 .includes(user: [{ avatar_attachment: :blob }, :discord_profile])
                 .action_uncompleted
                 .order(updated_at: :desc, id: :asc)
    @talks =
      if params[:search_word]
        @talks.merge(
          User.search_by_keywords({ word: params[:search_word] })
              .unscope(where: :retired_on)
        )
      else
        @talks.page(params[:page]).per(PAGER_NUMBER)
      end
  end
end

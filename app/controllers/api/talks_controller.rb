# frozen_string_literal: true

class API::TalksController < API::BaseController
  ALLOWED_TARGETS = %w[all student_and_trainee mentor graduate adviser trainee retired].freeze
  PAGER_NUMBER = 20

  def index
    @target = params[:target]
    @talks = Talk.joins(:user)
                 .includes(user: [{ avatar_attachment: :blob }, :discord_profile])
                 .order(updated_at: :desc, id: :asc)
    users = User.users_role(@target, allowed_targets: ALLOWED_TARGETS, default_target: 'all')
    @talks =
      if params[:search_word]
        searched_users = users.search_by_keywords({ word: params[:search_word] }).unscope(where: :retired_on)
        @talks.merge(
          @target == 'retired' ? searched_users.retired : searched_users
        )
      else
        @talks.merge(users)
              .page(params[:page]).per(PAGER_NUMBER)
      end
  end

  def update
    talk = Talk.find(params[:id])
    talk.update(talk_params)
  end

  private

  def talk_params
    params.require(:talk).permit(:action_completed)
  end
end

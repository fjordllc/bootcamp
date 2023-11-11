# frozen_string_literal: true

class API::TalksController < API::BaseController
  TARGETS = %w[all student_and_trainee mentor graduate adviser trainee retired].freeze
  PAGER_NUMBER = 20

  def index
    @target = params[:target]
    @target = 'all' unless TARGETS.include?(@target)
    @talks = Talk.joins(:user)
                 .includes(user: [{ avatar_attachment: :blob }, :discord_profile])
                 .order(updated_at: :desc, id: :asc)
    @talks =
      if params[:search_word]
        @talks.merge(
          User.search_by_keywords({ word: params[:search_word] })
              .unscope(where: :retired_on)
              .users_role(@target)
        )
      else
        @talks.merge(User.users_role(@target))
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

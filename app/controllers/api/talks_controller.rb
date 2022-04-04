# frozen_string_literal: true

class API::TalksController < API::BaseController
  TARGETS = %w[all student_and_trainee mentor graduate adviser trainee retired].freeze
  PAGER_NUMBER = 20

  def index
    @target = params[:target]
    @target = 'all' unless TARGETS.include?(@target)
    @talks = Talk.eager_load(user: [:company, { avatar_attachment: :blob }])
                 .merge(User.users_role(@target))
                 .order(updated_at: :desc)
    @talks =
      if params[:search_word]
        @talks.search_by_user_keywords(params[:search_word])
      else
        @talks.page(params[:page]).per(PAGER_NUMBER)
      end
  end
end

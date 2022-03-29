# frozen_string_literal: true

class API::TalksController < API::BaseController
  TARGETS = %w[all student_and_trainee mentor graduate adviser trainee retired].freeze
  PAGER_NUMBER = 20

  def index
    @target = params[:target]
    @target = 'all' unless TARGETS.include?(@target)
    @users_talks = Talk.required_list_data(@target).order(updated_at: :desc)
    @users_talks =
      if params[:search_word]
        @users_talks.search_by_user_keywords(params[:search_word])
      else
        @users_talks.page(params[:page]).per(PAGER_NUMBER)
      end
  end
end

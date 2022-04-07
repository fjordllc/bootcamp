# frozen_string_literal: true

class API::TalksController < API::BaseController
  TARGETS = %w[student_and_trainee mentor graduate adviser trainee retired all].freeze
  PAGER_NUMBER = 20

  def index
    @target = params[:target]
    @target = 'student_and_trainee' unless TARGETS.include?(@target)
    @users_talks = Talk.eager_load(user: [:company, { avatar_attachment: :blob }])
                       .merge(User.users_role(@target))
                       .page(params[:page]).per(PAGER_NUMBER)
                       .order(updated_at: :desc)
  end
end

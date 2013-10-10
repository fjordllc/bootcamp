class LearningsController < ApplicationController
  before_action :set_practice, only: %i(update)
  layout false

  def update
    learning = Learning.find_or_create_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )
    learning.status = params[:status].to_sym

    notify("#{current_user.full_name}(#{current_user.login_name})が「#{@practice.title}」を#{t(learning.status)}しました。 #{url_for(@practice)}")

    head :ok if learning.save
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end
end

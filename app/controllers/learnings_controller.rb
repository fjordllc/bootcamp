class LearningsController < ApplicationController
  before_action :set_practice, only: %w[create update]
  layout false

  def create
    learning = Learning.new(
      user_id:     current_user.id,
      practice_id: params[:practice_id]
    )

    notify("#{current_user.full_name}(#{current_user.login_name})が「#{@practice.title}」を始めました。 #{url_for(@practice)}")
    head :ok if learning.save
  end

  def update
    learning = Learning.find_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

    notify("#{current_user.full_name}(#{current_user.login_name})が「#{@practice.title}」を完了しました。 #{url_for(@practice)}")
    learning.status = :complete
    head :ok if learning.save
  end

  def destroy
    learning = Learning.find_by(
     user_id: current_user.id,
     practice_id: params[:practice_id]
    )

    head :ok if learning.destroy
  end

  private
    def set_practice
      @practice = Practice.find(params[:practice_id])
    end

    def notify(text)
      Lingman::Updater.update(
        ENV['BOT_ID'],
        ENV['ROOM_ID'],
        ENV['SECRET'],
        text
      ) if Rails.env.production?
    end
end

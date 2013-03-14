class LearningsController < ApplicationController
  before_action :set_practice, only: %i(start finish)
  layout false

  def start
    learning = Learning.new(
      user_id:     current_user.id,
      practice_id: params[:practice_id]
    )

    notify("#{current_user.name}が「#{@practice.title}」を始めました。 #{url_for(@practice)}") if Rails.env.production?
    head :ok if learning.save
  end

  def finish
    learning = Learning.find_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

    notify("#{current_user.name}が「#{@practice.title}」を完了しました。 #{url_for(@practice)}") if Rails.env.production?
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
        Settings.bot_id,
        Settings.room_id,
        Settings.secret,
        text
      )
    end
end

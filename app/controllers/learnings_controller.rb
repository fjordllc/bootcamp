class LearningsController < ApplicationController
  before_action :set_practice, only: %i(start finish)
  layout false

  def start
    learning = Learning.new(
      user_id:     current_user.id,
      practice_id: params[:practice_id]
    )

    if Rails.env.production?
      notify("#{current_user.last_name} #{current_user.first_name}(#{current_user.login_name})が「#{@practice.title}」を始めました。 #{url_for(@practice)}")
    end
    head :ok if learning.save
  end

  def finish
    learning = Learning.find_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

    if Rails.env.production?
      notify("#{current_user.last_name} #{current_user.first_name}(#{current_user.login_name})が「#{@practice.title}」を完了しました。 #{url_for(@practice)}")
    end
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
      )
    end
end

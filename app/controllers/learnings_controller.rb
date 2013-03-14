class LearningsController < ApplicationController
  layout false

  def start
    learning = Learning.new(
      user_id:     current_user.id,
      practice_id: params[:practice_id]
    )

    head :ok if learning.save
  end

  def finish
    learning = Learning.find_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )

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
end

# frozen_string_literal: true

class API::Practices::Learning::CompletionMessageController < API::BaseController
  def update
    learning = Learning.find_by(
      user_id: current_user.id,
      practice_id: params[:practice_id]
    )
    if learning.update(completion_message_displayed: true)
      head :ok
    else
      head :bad_request
    end
  end
end

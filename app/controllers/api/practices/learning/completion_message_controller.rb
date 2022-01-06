# frozen_string_literal: true

class API::Practices::Learning::CompletionMessageController < API::BaseController
  def update
    learning = current_user.learnings.find_by(practice_id: params[:practice_id])
    if learning.update(completion_message_displayed: true)
      head :ok
    else
      head :bad_request
    end
  end
end

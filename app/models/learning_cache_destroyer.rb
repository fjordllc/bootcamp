# frozen_string_literal: true

class LearningCacheDestroyer
  def call(payload)
    user = payload[:user]
    Rails.cache.delete "/model/user/#{user.id}/completed_percentage"
    Rails.logger.info "[LearningCacheDestroyer] Cache destroyed for user #{user.id}"
  end
end

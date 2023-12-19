# frozen_string_literal: true

class LearningCacheDestroyer
  def call(payload)
    user = payload[:user]
    Rails.cache.delete "/model/user/#{user.id}/completed_percentage"
  end
end

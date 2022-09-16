# frozen_string_literal: true

class LearningCacheDestroyer
  def call(user)
    Rails.cache.delete "/model/user/#{user.id}/completed_percentage"
  end
end

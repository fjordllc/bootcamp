# frozen_string_literal: true

class LearningCallbacks
  def after_save(learning)
    delete_cache(learning.user.id)
  end

  def after_destroy(learning)
    delete_cache(learning.user.id)
  end

  private

  def delete_cache(user_id)
    Rails.cache.delete "/model/user/#{user_id}/completed_percentage"
  end
end

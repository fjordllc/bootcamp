# frozen_string_literal: true

class LearningCacheDestroyer
  ##
  # Deletes the completed percentage cache entry for a user and logs the cache destruction event.
  # @param payload [Hash] The payload containing the user whose cache should be cleared.
  def call(_name, _started, _finished, _unique_id, payload)
    user = payload[:user]
    Rails.cache.delete "/model/user/#{user.id}/completed_percentage"
    Rails.logger.info "[LearningCacheDestroyer] Cache destroyed for user #{user.id}"
  end
end

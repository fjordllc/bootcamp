# frozen_string_literal: true

Rails.configuration.after_initialize do
  ActiveSupport::Notifications.subscribe('answer.create', AnswererWatcher.new)
end

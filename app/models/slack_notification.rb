# frozen_string_literal: true

class SlackNotification
  def self.notify(text, options = {})
    NoticeSlackJob.perform_later(text, options)
  end
end

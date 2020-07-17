# frozen_string_literal: true

module Mentioner
  def after_save_mention(mentions)
    mentions.map { |s| s.gsub(/@/, "") }.each do |mention|
      receiver = User.find_by(login_name: mention)
      if receiver && sender != receiver
        NotificationFacade.mentioned(self, receiver)
      end
    end
  end
end

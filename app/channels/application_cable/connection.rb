# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      User.find_by(id: session_data['user_id']) || reject_unauthorized_connection
    end

    def session_data
      cookies.encrypted[Rails.application.config.session_options[:key]]
    end
  end
end

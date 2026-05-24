# frozen_string_literal: true

class Pjord
  LOGIN_NAME = 'pjord'

  class << self
    def user
      User.find_by(login_name: LOGIN_NAME)
    end
  end
end

# frozen_string_literal: true

Switchlet.configure do |config|
  config.authenticate_with do |controller|
    User.find_by(id: controller.session[:user_id])&.admin?
  end
end

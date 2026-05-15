# frozen_string_literal: true

class MailsController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  layout false

  def welcome; end
end

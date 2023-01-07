# frozen_string_literal: true

class MailsController < ApplicationController
  skip_before_action :require_login, raise: false
  skip_before_action :require_current_student, raise: false
  layout false

  def welcome; end
end

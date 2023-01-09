# frozen_string_literal: true

class MailsController < ApplicationController
  skip_before_action :require_login, raise: false
  skip_before_action :refuse_retired_login, raise: false
  skip_before_action :refuse_hibernated_login, raise: false
  layout false

  def welcome; end
end

# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
end

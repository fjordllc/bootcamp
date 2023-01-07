# frozen_string_literal: true

class StaticPagesController < ApplicationController
  skip_before_action :require_login, raise: false
  skip_before_action :require_current_student, raise: false
end

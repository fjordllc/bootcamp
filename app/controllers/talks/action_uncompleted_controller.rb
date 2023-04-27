# frozen_string_literal: true

class Talks::ActionUncompletedController < ApplicationController
  before_action :require_admin_login
  def index; end
end

# frozen_string_literal: true

class PaperController < ApplicationController
  before_action :require_admin_login
  layout 'paper'
end

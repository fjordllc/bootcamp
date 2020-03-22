# frozen_string_literal: true

class API::BaseController < ApplicationController
  before_action :require_login
end

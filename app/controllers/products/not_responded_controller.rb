# frozen_string_literal: true

class Products::NotRespondedController < ApplicationController
  before_action :require_staff_login
  def index; end
end

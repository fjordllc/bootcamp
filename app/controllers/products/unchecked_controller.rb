# frozen_string_literal: true

class Products::UncheckedController < ApplicationController
  before_action :require_staff_login
  def index; end
end

# frozen_string_literal: true

class Reports::UncheckedController < ApplicationController
  before_action :require_staff_login
  def index; end
end

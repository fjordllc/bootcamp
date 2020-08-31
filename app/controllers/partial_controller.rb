# frozen_string_literal: true

class PartialController < ApplicationController
  layout nil
  before_action :require_login
end

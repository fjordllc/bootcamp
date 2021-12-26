# frozen_string_literal: true

class Talks::UnrepliedController < ApplicationController
  before_action :require_staff_login
  def index; end
end

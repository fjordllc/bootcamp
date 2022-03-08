# frozen_string_literal: true

class Talks::UnrepliedController < ApplicationController
  before_action :require_admin_login
  def index; end
end

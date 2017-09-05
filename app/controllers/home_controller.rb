class HomeController < ApplicationController
  before_action :require_login, except: :welcome

  def index
  end

  def welcome
  end
end

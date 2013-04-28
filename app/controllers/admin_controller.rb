class AdminController < ApplicationController
  before_action :require_admin_login
end

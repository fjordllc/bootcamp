# frozen_string_literal: true

class Admin::HomeController < AdminController
  def index
    @users = User.students.where(company_id: 1)
  end
end

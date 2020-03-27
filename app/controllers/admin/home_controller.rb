# frozen_string_literal: true

class Admin::HomeController < AdminController
  def index
    @users = User.students_and_trainees.where(company_id: 1)
  end
end

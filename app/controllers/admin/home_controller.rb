class Admin::HomeController < AdminController
  def index
    @users = User.student.where(company_id: 1)
  end
end

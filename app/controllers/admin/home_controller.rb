class Admin::HomeController < AdminController
  def index
    @users = User.not_advisers.woke.where(company_id: 1)
  end
end

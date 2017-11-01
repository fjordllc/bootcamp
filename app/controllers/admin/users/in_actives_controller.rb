class Admin::Users::InActivesController < AdminController
  def index
    @users = User.where(adviser: false, retire: false, graduation: false).inactive.order(:updated_at)
  end
end

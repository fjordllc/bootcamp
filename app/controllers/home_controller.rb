class HomeController < ApplicationController
  def index
    if current_user.present?
      redirect_to controller: :users, action: :index
    end
  end

  #TODO 仮のお問い合わせページ（デザインのみシステム未実装、実装後削除）
  def contact
  end
end

# frozen_string_literal: true

class API::ProductsController < API::BaseController
  before_action :require_login
  before_action :require_staff_login, only: :index

  def index
    @products = Product
                .includes(
                  :practice,
                  { comments: { user: :avatar_attachment } },
                  { user: [{ avatar_attachment: :blob }, :company] },
                  { checks: { user: [:company] } }
                )
                .order(published_at: :desc)
                .page(params[:page])
  end
end

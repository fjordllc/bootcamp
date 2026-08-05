# frozen_string_literal: true

class API::PagesController < API::BaseController
  before_action :require_write_scope, only: %i[update]
  before_action :set_page, only: %i[update]

  def update
    @page.last_updated_user = current_user
    if @page.update(page_params)
      head :ok
    else
      head :bad_request
    end
  end

  private

  def set_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:tag_list, :body)
  end

  def require_write_scope
    return unless doorkeeper_token.present? || params[:page]&.key?(:body)

    doorkeeper_authorize! :write
  end
end

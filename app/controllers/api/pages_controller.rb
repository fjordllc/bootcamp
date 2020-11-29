# frozen_string_literal: true

class API::PagesController < API::BaseController
  before_action :set_page, only: %i(update)

  def update
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
    params.require(:page).permit(:tag_list)
  end
end

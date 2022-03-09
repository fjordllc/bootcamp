# frozen_string_literal: true

class API::PagesController < API::BaseController
  before_action :set_page, only: %i[update]

  def index
    if params[:practice_id]
      practice = Practice.find(params[:practice_id])
      @pages = practice.pages.with_avatar
                       .includes(:comments,
                                 { last_updated_user: { avatar_attachment: :blob } })
                       .order(updated_at: :desc)
                       .page(params[:page])
    else
      @pages = Page.with_avatar
                   .includes(:comments, :practice, :tags,
                             { last_updated_user: { avatar_attachment: :blob } })
                   .order(updated_at: :desc)
                   .page(params[:page])
      @pages = @pages.tagged_with(params[:tag]) if params[:tag]
    end
  end

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

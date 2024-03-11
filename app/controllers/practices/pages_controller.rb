# frozen_string_literal: true

class Practices::PagesController < ApplicationController
  PAGER_NUMBER = 20

  def index
    @practice = Practice.find(params[:practice_id])
    @pages = Page.with_avatar
                 .includes(:comments, :practice, { last_updated_user: { avatar_attachment: :blob } })
                 .where(practice_id: params[:practice_id])
                 .order(updated_at: :desc, id: :desc)
                 .page(params[:page])
                 .per(PAGER_NUMBER)
  end
end

# frozen_string_literal: true

class Practices::PagesController < ApplicationController
  PAGER_NUMBER = 20

  def index
    @practice = Practice.find(params[:practice_id])

    @pages = Page.with_avatar
                 .includes(:comments, :practice, { last_updated_user: { avatar_attachment: :blob } })
                 .where(practice_id: params[:practice_id])
    if current_user.grant_course? && @practice.grant_course? && params[:target] != 'with_grant'
      @pages = @pages.or(Page.source_cource_pages(@practice.source_id))
    end

    @pages = @pages.page(params[:page])
                   .per(PAGER_NUMBER)
                   .order(updated_at: :desc, id: :desc)
  end
end

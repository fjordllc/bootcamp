# frozen_string_literal: true

class Practices::PagesController < ApplicationController
  PAGER_NUMBER = 20

  def index
    @practice = Practice.find(params[:practice_id])
    source_practice = @practice.source_practice

    @pages = @practice.pages
                      .includes(:comments, :practice, { last_updated_user: { avatar_attachment: :blob } })

    if @practice.grant_course? && params[:target] != 'only_grant_course' && source_practice.pages.present?
      @pages = @pages.or(source_practice.pages).includes(:comments, :practice,
                                                         { last_updated_user: { avatar_attachment: :blob } })
    end

    @pages = @pages.order(updated_at: :desc, id: :desc)
                   .page(params[:page])
                   .per(PAGER_NUMBER)
  end
end

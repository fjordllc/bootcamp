# frozen_string_literal: true

class Practices::PagesController < ApplicationController
  def index
    @practice = Practice.find(params[:practice_id])
    @pages = Page.with_avatar
                 .includes(:comments, :practice, { last_updated_user: { avatar_attachment: :blob } })
                 .where(practice_id: params[:practice_id])
                 .order(updated_at: :desc, id: :desc)
  end
end

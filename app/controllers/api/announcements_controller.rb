# frozen_string_literal: true

class API::AnnouncementsController < API::BaseController
  def index
    pagination = API::Pagination.new(params)
    return render_bad_request unless pagination.valid?

    announcements = Announcement.where(wip: false).where(published_at: ..Time.current)
                                .order(published_at: :desc, id: :desc).page(pagination.page).per(pagination.per_page)
    render json: {
      announcements: announcements.map do |announcement|
        announcement.slice(:id, :title, :description, :target).merge(
          published_at: announcement.published_at.iso8601, url: announcement_path(announcement)
        )
      end,
      total_pages: announcements.total_pages
    }
  end
end

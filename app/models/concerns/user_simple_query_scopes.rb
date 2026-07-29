# frozen_string_literal: true

module UserSimpleQueryScopes
  extend ActiveSupport::Concern

  included do
    scope :by_course, ->(target) { joins(:course).where(courses: { title: target }) }
    scope :classmates, lambda { |start_date, end_date|
      where(created_at: start_date..end_date).order(:created_at, :id)
    }
    scope :campaign, -> { where(created_at: Campaign.recently_campaign) }
    columns_for_keyword_search(
      :login_name,
      :name,
      :name_kana,
      :twitter_account,
      :facebook_url,
      :blog_url,
      :github_account,
      :description
    )
  end
end

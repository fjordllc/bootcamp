# frozen_string_literal: true

module MentorIndexScopes
  extend ActiveSupport::Concern

  included do
    scope :mentors_sorted_by_created_at, lambda {
      with_attached_profile_image
        .mentor
        .includes(authored_books: { cover_attachment: :blob })
        .order(:created_at)
    }
    scope :visible_sorted_mentors, lambda {
      with_attached_profile_image
        .mentor
        .includes(authored_books: { cover_attachment: :blob })
        .order(:created_at)
        .where(show_mentor_profile: true)
    }
  end
end

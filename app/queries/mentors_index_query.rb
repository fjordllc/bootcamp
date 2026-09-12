# frozen_string_literal: true

class MentorsIndexQuery < Patterns::Query
  queries User

  private

  def initialize(relation = User.all, visible_only: false)
    super(relation)
    @visible_only = visible_only
  end

  def query
    scoped = relation
             .with_attached_profile_image
             .mentor
             .includes(authored_books: { cover_attachment: :blob })
             .order(:created_at)
    @visible_only ? scoped.where(show_mentor_profile: true) : scoped
  end
end

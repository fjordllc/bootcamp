# frozen_string_literal: true

class DelayedUsersQuery < Patterns::Query
  queries User

  private

  def initialize(relation = User.all)
    super(relation)
  end

  def query
    relation
      .students_and_trainees
      .joins("JOIN (#{completed_learnings_sql}) learnings ON users.id = user_id")
      .select('users.*', :completed_at)
      .where('completed_at <= ?', 2.weeks.ago.end_of_day)
  end

  def completed_learnings_sql
    Learning.select(:user_id, 'MAX(updated_at) AS completed_at')
            .where(status: :complete)
            .group(:user_id).to_sql
  end
end

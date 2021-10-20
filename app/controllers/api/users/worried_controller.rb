# frozen_string_literal: true

class API::Users::WorriedController < API::BaseController
  before_action :require_login

  def index
    sql = Learning.select(:user_id, 'MAX(updated_at) AS completed_at')
                  .where(status: 3)
                  .group(:user_id).to_sql

    @worried_users = User.students_and_trainees
                         .joins("JOIN (#{sql}) learnings ON users.id = user_id")
                         .select('users.*', :completed_at)
                         .where('completed_at <= ?', 2.weeks.ago.end_of_day)
                         .order(completed_at: :asc)
  end
end

# frozen_string_literal: true

class CurrentlyLearningUsersExceptQuery < Patterns::Query
  queries User

  private

  def initialize(relation = User.all, user:)
    super(relation)
    @user = user
  end

  def query
    relation
      .students_and_trainees
      .joins(:learning_time_frames)
      .merge(LearningTimeFrame.active_now)
      .where.not(id: @user.id)
      .with_attached_avatar
  end
end

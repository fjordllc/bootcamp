# frozen_string_literal: true

class ColleagueTraineesRecentReportsQuery < Patterns::Query
  queries Report

  private

  def query
    relation
      .joins(:user)
      .where(users: { id: colleague_trainee_ids })
      .not_wip
      .default_order
      .with_avatar
  end

  def initialize(relation = Report.all, current_user:)
    super(relation)
    @current_user = current_user
  end

  def colleague_trainee_ids
    UserColleagues.new(@current_user).colleague_trainees.pluck(:id)
  end
end

# frozen_string_literal: true

class DepressedReportsQuery < Patterns::Query
  queries Report

  private

  def initialize(relation = Report.all)
    super(relation)
  end

  def query
    ids = User.where(
      hibernated_at: nil,
      training_completed_at: nil,
      retired_on: nil,
      graduated_on: nil,
      negative_streak: true
    ).pluck(:last_negative_report_id)
    relation.joins(:user).where(id: ids).order(reported_on: :desc)
  end
end

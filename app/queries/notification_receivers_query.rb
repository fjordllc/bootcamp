# frozen_string_literal: true

class NotificationReceiversQuery < Patterns::Query
  queries User

  private

  def initialize(relation = User.all, target:)
    super(relation)
    @target = target
  end

  def query
    case @target
    when 'all' then relation.unretired
    when 'students' then relation.admins_and_mentors.or(relation.students)
    when 'job_seekers' then relation.admins_and_mentors.or(relation.job_seekers)
    else relation.none
    end
  end
end

# frozen_string_literal: true

class UserColleagues
  def initialize(user)
    @user = user
  end

  def colleagues
    @user.company_id ? @user.company.users : User.none
  end

  def colleagues_other_than_self
    colleagues.where.not(id: @user.id)
  end

  def colleague_trainees
    colleagues.students_and_trainees
  end
end

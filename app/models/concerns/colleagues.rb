# frozen_string_literal: true

module Colleagues
  extend ActiveSupport::Concern

  def belongs_company_and_adviser?
    adviser? && company_id?
  end

  def colleagues
    company_id ? company.users : User.none
  end

  def colleagues_other_than_self
    colleagues.where.not(id:)
  end

  def colleague_trainees
    colleagues.students_and_trainees
  end
end

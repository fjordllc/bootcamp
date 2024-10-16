# frozen_string_literal: true

class Users::MicroReports::FormComponent < ViewComponent::Base
  def initialize(user:)
    @user = user
    @micro_report = user.micro_reports.build
  end
end

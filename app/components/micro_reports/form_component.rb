# frozen_string_literal: true

class MicroReports::FormComponent < ViewComponent::Base
  def initialize(user:, controller_name: nil)
    @user = user
    @controller_name = controller_name
    @micro_report = user.micro_reports.build
  end

  def form_action_path
    case @controller_name
    when 'Users::MicroReportsController'
      helpers.user_micro_reports_path(@user, anchor: 'latest-micro-report')
    when 'CurrentUser::MicroReportsController'
      helpers.current_user_micro_reports_path(anchor: 'latest-micro-report')
    else
      raise "Unsupported controller: #{@controller_name}"
    end
  end
end

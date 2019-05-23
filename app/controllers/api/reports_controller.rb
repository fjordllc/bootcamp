# frozen_string_literal: true

class API::ReportsController < API::BaseController
  def show
    @report = Report.find(params[:id])
    @check = @report.checks&.last
    @checked_user = @check&.user&.login_name
    @check_craeted_at = @check.present? ? I18n.l(@check.created_at.to_date, format: :short) : nil
  end
end

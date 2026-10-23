# frozen_string_literal: true

class PerformanceReportsController < ApplicationController
  skip_before_action :test_login, :save_affiliate_rd_code, :set_current_user_practice
  prepend_before_action :validate_origin
  prepend_before_action :require_active_user_login
  before_action :collection_enabled
  prepend_before_action -> { response.headers['Cache-Control'] = 'no-store' }
  rescue_from ActionController::InvalidAuthenticityToken, with: -> { head :unprocessable_entity }

  def create
    report = Performance::Report.new(request.request_parameters)
    return head :bad_request unless report.valid?

    result = Performance::ReportGate.new.accept(token: report.token, session_binding: performance_session_binding, page: report.page)
    Performance::LogWriter.new.browser(page: report.page, device: report.device, metrics: report.metrics) if result == :accepted
    head({ accepted: :no_content, duplicate: :no_content, invalid: :unprocessable_entity, limited: :too_many_requests,
           busy: :service_unavailable, unavailable: :service_unavailable }.fetch(result))
  end

  private

  def require_active_user_login
    return head :unauthorized unless logged_in?

    head :forbidden if inactive_login?
  end

  def validate_origin
    response.headers['Cache-Control'] = 'no-store'
    host = ENV['APP_HOST_NAME'].to_s
    valid = host.match?(/\A[a-zA-Z0-9.-]+(?::[0-9]+)?\z/) && request.headers['Origin'] == "https://#{host}"
    valid &&= request.host_with_port == host && request.ssl?
    site = request.headers['Sec-Fetch-Site']
    head :forbidden unless valid && (site.nil? || site == 'same-origin')
  end

  def collection_enabled
    head :service_unavailable unless Performance::Configuration.new.collection?
  end
end

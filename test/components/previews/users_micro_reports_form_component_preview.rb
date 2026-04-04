# frozen_string_literal: true

class UsersMicroReportsFormComponentPreview < ViewComponent::Preview
  include PreviewHelper

  def default
    user = build_mock_user
    micro_report = MockMicroReport.new
    reports_proxy = OpenStruct.new(build: micro_report)
    user.define_singleton_method(:micro_reports) { reports_proxy }

    render(Users::MicroReports::FormComponent.new(user: user))
  end

  # form_withで使えるActiveModel準拠のモック
  class MockMicroReport
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :integer
    attribute :content, :string, default: ''
    attribute :created_at

    def persisted? = false

    def model_name
      ActiveModel::Name.new(nil, nil, 'MicroReport')
    end
  end
end

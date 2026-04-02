# frozen_string_literal: true

class UsersMicroReportsFormComponentPreview < ViewComponent::Preview
  def default
    user = OpenStruct.new(
      id: 1,
      login_name: 'yamada',
      name: '山田太郎',
      micro_reports: OpenStruct.new(
        build: OpenStruct.new(
          id: nil,
          content: '',
          created_at: nil
        )
      )
    )

    render(Users::MicroReports::FormComponent.new(user: user))
  end
end
# frozen_string_literal: true

module ProductDecorator
  def list_title(resource)
    case resource
    when Practice
      user.login_name
    when User
      practice.title
    end
  end
end

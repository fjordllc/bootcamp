# frozen_string_literal: true

# Lookbook previewのユーザーモックに共通メソッドを追加するヘルパー
module PreviewHelper
  def add_user_routing_methods(user)
    login = user.login_name
    user.define_singleton_method(:to_param) { login }
    user.define_singleton_method(:persisted?) { true }
    user.define_singleton_method(:model_name) do
      OpenStruct.new(route_key: 'users', singular_route_key: 'user', param_key: 'user')
    end
    user.define_singleton_method(:icon_classes) do |image_class|
      ['a-user-icon', image_class].compact.join(' ')
    end
    user.user_icon_frame_class ||= "a-user-role is-#{user.primary_role || 'student'}"
    user
  end
end

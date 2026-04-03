# frozen_string_literal: true

# Lookbook previewで使う共通モッククラス
module PreviewHelper
  # ActiveModelに準拠したユーザーモック
  class MockUser
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :integer
    attribute :login_name, :string
    attribute :name, :string
    attribute :name_kana, :string
    attribute :long_name, :string
    attribute :primary_role, :string, default: 'student'
    attribute :joining_status, :string, default: 'active'
    attribute :avatar_url, :string, default: 'https://via.placeholder.com/40'
    attribute :icon_title, :string
    attribute :training_ends_on
    attribute :training_remaining_days

    def persisted? = true
    def to_param = login_name

    def icon_classes(image_class)
      ['a-user-icon', image_class].compact.join(' ')
    end

    def user_icon_frame_class
      "a-user-role is-#{primary_role}"
    end

    def model_name
      ActiveModel::Name.new(nil, nil, 'User')
    end

    def online? = false
    def admin? = false
    def mentor? = primary_role == 'mentor'
    def graduated? = false
  end

  # ActiveModelに準拠した汎用リソースモック
  class MockResource
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :id, :integer

    def persisted? = true
    def to_param = id.to_s
  end

  def build_mock_user(attrs = {})
    defaults = { id: 1, login_name: 'yamada', name: 'yamada', icon_title: 'yamada' }
    PreviewHelper::MockUser.new(defaults.merge(attrs))
  end
end

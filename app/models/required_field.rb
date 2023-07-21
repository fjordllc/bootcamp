# frozen_string_literal: true

class RequiredField
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :avatar_attached, :boolean
  attribute :tag_list_count, :integer
  attribute :after_graduation_hope, :string
  attribute :discord_account_name, :string
  attribute :github_account, :string
  attribute :blog_url, :string
  attribute :graduated, :boolean

  validates :avatar_attached, presence: { message: 'ユーザーアイコンを登録してください。' }
  validates :tag_list_count, numericality: { greater_than: 0, message: 'タグを登録してください。' }
  validates :after_graduation_hope, presence: { message: 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。' }, unless: :graduated
  # Todo Discord の ID のルールが変更になったので、それに対応できるまで隠す。
  # validates :discord_account, presence: { message: 'Discordアカウントを登録してください。' }
  validates :github_account, presence: { message: 'GitHubアカウントを登録してください。' }
  validates :blog_url, presence: { message: 'ブログURLを登録してください。' }
end

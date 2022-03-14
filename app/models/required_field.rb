# frozen_string_literal: true

class RequiredField
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :avatar_attached, :boolean
  attribute :tag_list_count, :integer
  attribute :after_graduation_hope, :string
  attribute :discord_account, :string
  attribute :github_account, :string
  attribute :blog_url, :string

  validates :avatar_attached, presence: { message: 'ユーザーアイコンを登録してください。' }
  validates :tag_list_count, numericality: { greater_than: 0, message: 'タグを登録してください。' }
  validates :after_graduation_hope, presence: { message: 'フィヨルドブートキャンプを卒業した自分はどうなっていたいかを登録してください。' }
  validates :discord_account, presence: { message: 'Discordアカウントを登録してください。' }
  validates :github_account, presence: { message: 'GitHubアカウントを登録してください。' }
  validates :blog_url, presence: { message: 'ブログURLを登録してください。' }
end

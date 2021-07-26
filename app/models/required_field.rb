# frozen_string_literal: true

class RequiredField
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :description, :string
  attribute :github_account, :string
  attribute :discord_account, :string

  validates :description, presence: true
  validates :github_account, presence: { message: 'GitHubアカウントを登録してください。' }
  validates :discord_account, presence: { message: 'Discordアカウントを登録してください。' }
end

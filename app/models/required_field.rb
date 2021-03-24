# frozen_string_literal: true

class RequiredField
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :description, :string
  attribute :github_account, :string
  attribute :slack_account, :string
  attribute :discord_account, :string

  validates :description, presence: true
  validates :github_account, presence: { message: 'を登録してください。' }
  validates :slack_account, presence: { message: 'を登録してください。' }
  validates :discord_account, presence: { message: 'を登録してください。' }
end

# frozen_string_literal: true

class OauthAccessToken < ApplicationRecord
  belongs_to :user
end

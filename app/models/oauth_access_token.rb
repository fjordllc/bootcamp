# frozen_string_literal: true

class OauthAccessToken < ApplicationRecord
  belongs_to :user,
             class_name: 'User'
end

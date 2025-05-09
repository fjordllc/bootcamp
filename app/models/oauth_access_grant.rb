# frozen_string_literal: true

class OauthAccessGrant < ApplicationRecord
  belongs_to :user
end

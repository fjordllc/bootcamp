# frozen_string_literal: true

class Talk < ApplicationRecord
  include Commentable

  belongs_to :user
end

# frozen_string_literal: true

class Image < ActiveRecord::Base
  belongs_to :user
  has_one_attached :image
end

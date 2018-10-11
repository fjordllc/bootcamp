# frozen_string_literal: true

class Image < ActiveRecord::Base
  belongs_to :user
  has_attached_file :image, styles: { normal: "736x736>" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/
end

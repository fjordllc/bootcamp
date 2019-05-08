# frozen_string_literal: true

module WorkDecorator
  def thumbnail_image(length)
    rails_blob_path(thumbnail)
  end
end

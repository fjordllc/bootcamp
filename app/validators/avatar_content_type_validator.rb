# frozen_string_literal: true

class AvatarContentTypeValidator < ActiveModel::EachValidator
  ALLOWED_TYPES = %w[
    image/png
    image/jpeg
    image/gif
    image/heic
    image/heif
  ].freeze

  def validate_each(record, _attribute, value)
    return if value.blank?
    return if Marcel::Magic.by_magic(value)&.type.in?(ALLOWED_TYPES)

    record.errors.add(
      :avatar,
      'は指定された拡張子(PNG, JPG, JPEG, GIF, HEIC, HEIF形式)になっていないか、あるいは画像が破損している可能性があります'
    )
  end
end

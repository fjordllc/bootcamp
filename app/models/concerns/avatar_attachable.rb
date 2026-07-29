# frozen_string_literal: true

module AvatarAttachable
  extend ActiveSupport::Concern

  included do
    validate :validate_uploaded_avatar_content_type
  end

  def avatar_url
    if avatar.attached? && avatar.blob.present?
      custom_key = "avatars/#{login_name}.#{User::AVATAR_FORMAT}"
      attach_custom_avatar if avatar.blob.key != custom_key
      "#{avatar.url}?v=#{avatar.created_at.to_i}"
    else
      image_url User::DEFAULT_IMAGE_PATH
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::Error => e
    log_avatar_error('avatar_url', e)
    image_url User::DEFAULT_IMAGE_PATH
  end

  def profile_image_url
    if profile_image.attached?
      profile_image
    else
      image_url User::DEFAULT_IMAGE_PATH
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::Error => e
    log_avatar_error('profile_image_url', e)
    image_url User::DEFAULT_IMAGE_PATH
  end

  def validate_uploaded_avatar_content_type
    return unless uploaded_avatar

    mime_type = Marcel::Magic.by_magic(uploaded_avatar)&.type
    return if mime_type&.start_with?('image/png', 'image/jpeg', 'image/gif', 'image/heic', 'image/heif')

    errors.add(:avatar, 'は指定された拡張子(PNG, JPG, JPEG, GIF, HEIC, HEIF形式)になっていないか、あるいは画像が破損している可能性があります')
  end

  private

  def attach_custom_avatar
    custom_key = "avatars/#{login_name}.#{User::AVATAR_FORMAT}"
    variant_avatar = avatar.variant(resize_to_fill: User::AVATAR_SIZE, autorot: true, saver: { strip: true, quality: 60 }, format: User::AVATAR_FORMAT).processed
    io = StringIO.new(variant_avatar.download)

    # Use ActiveStorage's create_and_upload! for proper checksum handling
    custom_blob = ActiveStorage::Blob.find_by(key: custom_key)

    unless custom_blob
      custom_blob = ActiveStorage::Blob.create_and_upload!(
        io:,
        filename: "#{login_name}.#{User::AVATAR_FORMAT}",
        content_type: "image/#{User::AVATAR_FORMAT}",
        key: custom_key,
        identify: false
      )
      avatar.attach(custom_blob)
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::Error, LoadError => e
    log_avatar_error('attach_custom_avatar', e)
  end

  def log_avatar_error(context, error)
    Rails.logger.error "[#{context}] Avatar processing failed for user #{login_name}: #{error.message}"
  end
end

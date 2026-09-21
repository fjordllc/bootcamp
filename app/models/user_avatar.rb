# frozen_string_literal: true

class UserAvatar
  def initialize(user)
    @user = user
  end

  def avatar_url
    if @user.avatar.attached? && @user.avatar.blob.present?
      custom_key = "avatars/#{@user.login_name}.#{User::AVATAR_FORMAT}"
      attach_custom_avatar if @user.avatar.blob.key != custom_key
      return @user.image_url User::DEFAULT_IMAGE_PATH unless @user.avatar.blob.service.exist?(@user.avatar.blob.key)

      "#{@user.avatar.url}?v=#{@user.avatar.created_at.to_i}"
    else
      @user.image_url User::DEFAULT_IMAGE_PATH
    end
  rescue ActiveStorage::Error => e
    log_avatar_error('avatar_url', e)
    @user.image_url User::DEFAULT_IMAGE_PATH
  end

  def profile_image_url
    if @user.profile_image.attached?
      @user.profile_image
    else
      @user.image_url User::DEFAULT_IMAGE_PATH
    end
  rescue ActiveStorage::FileNotFoundError, ActiveStorage::Error => e
    log_avatar_error('profile_image_url', e)
    @user.image_url User::DEFAULT_IMAGE_PATH
  end

  private

  def attach_custom_avatar
    custom_key = "avatars/#{@user.login_name}.#{User::AVATAR_FORMAT}"
    custom_blob = ActiveStorage::Blob.find_by(key: custom_key)

    unless custom_blob
      variant_avatar = @user.avatar.variant(resize_to_fill: User::AVATAR_SIZE, autorot: true, saver: { strip: true, quality: 60 }, format: User::AVATAR_FORMAT).processed
      io = StringIO.new(variant_avatar.download)

      custom_blob = ActiveStorage::Blob.create_and_upload!(
        io:,
        filename: "#{@user.login_name}.#{User::AVATAR_FORMAT}",
        content_type: "image/#{User::AVATAR_FORMAT}",
        key: custom_key,
        identify: false
      )
    end
    @user.avatar.attach(custom_blob)
  end

  def log_avatar_error(context, error)
    Rails.logger.error "[#{context}] Avatar processing failed for user #{@user.login_name}: #{error.message}"
  end
end

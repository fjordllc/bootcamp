# coding: utf-8
module UserDecorator
  def icon_url
    digest =
      if email.present?
        Digest::MD5::hexdigest(email).downcase
      else
        '0' * 32
      end
    "http://gravatar.com/avatar/#{digest}.png?s=96"
  end
end

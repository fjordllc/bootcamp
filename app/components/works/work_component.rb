# frozen_string_literal: true

class Works::WorkComponent < ViewComponent::Base
  include UsersHelper
  
  def initialize(work:)
    @work = work
  end

  def thumbnail
    if work.thumbnail.attached?
      image_tag work.thumbnail_url, class: 'thumbnail-card__image'
    else
      image_tag('work-blank.svg', class: 'thumbnail-card__image')
    end
  end

  def creator_avatar
    image_tag work.user.avatar_url, title: work.user.icon_title, class: 'a-user-icons__item-icon a-user-icon'
  end

  private

  attr_reader :work
end

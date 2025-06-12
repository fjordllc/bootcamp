# frozen_string_literal: true

class Works::WorkComponent < ViewComponent::Base
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

  def user_role_status_span(user, &)
    tag.span(class: ['a-user-role', "is-#{user.primary_role}", "is-#{user.joining_status}"], &)
  end

  private

  attr_reader :work
end

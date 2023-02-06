# frozen_string_literal: true

class PageNotifier
  def call(page)
    return if page.wip?

    create_author_watch(page)
  end

  private

  def create_author_watch(page)
    Watch.create!(user: page.user, watchable: page)
  end
end

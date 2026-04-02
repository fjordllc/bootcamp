# frozen_string_literal: true

class WorksWorkComponentPreview < ViewComponent::Preview
  def default
    work = mock_work

    render(Works::WorkComponent.new(work: work))
  end

  def with_thumbnail
    work = mock_work(has_thumbnail: true)

    render(Works::WorkComponent.new(work: work))
  end

  def without_thumbnail
    work = mock_work(has_thumbnail: false)

    render(Works::WorkComponent.new(work: work))
  end

  private

  def mock_work(has_thumbnail: false)
    user = OpenStruct.new(
      id: 1,
      login_name: 'creator',
      name: 'クリエイター',
      avatar_url: 'https://via.placeholder.com/40',
      icon_title: 'クリエイター'
    )

    thumbnail = if has_thumbnail
                  OpenStruct.new(
                    attached?: true,
                    url: 'https://via.placeholder.com/300x200'
                  )
                else
                  OpenStruct.new(attached?: false)
                end

    OpenStruct.new(
      id: 1,
      title: 'Webアプリケーション作品',
      description: 'Railsで作ったTODOアプリです',
      user: user,
      thumbnail: thumbnail,
      thumbnail_url: has_thumbnail ? 'https://via.placeholder.com/300x200' : nil,
      created_at: 1.week.ago
    )
  end
end
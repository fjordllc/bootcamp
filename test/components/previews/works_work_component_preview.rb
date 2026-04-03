# frozen_string_literal: true

class WorksWorkComponentPreview < ViewComponent::Preview
  include PreviewHelper

  def default
    render(Works::WorkComponent.new(work: mock_work))
  end

  def with_thumbnail
    render(Works::WorkComponent.new(work: mock_work(has_thumbnail: true)))
  end

  def without_thumbnail
    render(Works::WorkComponent.new(work: mock_work))
  end

  private

  def mock_thumbnail(has_thumbnail)
    return OpenStruct.new(attached?: false) unless has_thumbnail

    OpenStruct.new(attached?: true, url: 'https://via.placeholder.com/300x200')
  end

  def mock_work(has_thumbnail: false)
    user = build_mock_user(login_name: 'creator', name: 'クリエイター', icon_title: 'クリエイター')
    work = OpenStruct.new(
      id: 1, title: 'Webアプリケーション作品', description: 'Railsで作ったTODOアプリです',
      user: user, thumbnail: mock_thumbnail(has_thumbnail),
      thumbnail_url: has_thumbnail ? 'https://via.placeholder.com/300x200' : nil,
      created_at: 1.week.ago
    )
    work.define_singleton_method(:to_param) { '1' }
    work.define_singleton_method(:persisted?) { true }
    work.define_singleton_method(:model_name) { ActiveModel::Name.new(nil, nil, 'Work') }
    work
  end
end

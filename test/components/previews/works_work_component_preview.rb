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

  def mock_work_user
    user = OpenStruct.new(
      id: 1, login_name: 'creator', name: 'クリエイター',
      primary_role: 'student',
      avatar_url: 'https://via.placeholder.com/40', icon_title: 'クリエイター',
      user_icon_frame_class: 'a-user-role is-student'
    )
    user.define_singleton_method(:icon_classes) { |image_class| ['a-user-icon', image_class].compact.join(' ') }
    user.define_singleton_method(:to_param) { 'creator' }
    user.define_singleton_method(:persisted?) { true }
    user.define_singleton_method(:model_name) { OpenStruct.new(route_key: 'users', singular_route_key: 'user') }
    user
  end

  def mock_thumbnail(has_thumbnail)
    return OpenStruct.new(attached?: false) unless has_thumbnail

    OpenStruct.new(attached?: true, url: 'https://via.placeholder.com/300x200')
  end

  def mock_work(has_thumbnail: false)
    OpenStruct.new(
      id: 1, title: 'Webアプリケーション作品', description: 'Railsで作ったTODOアプリです',
      user: mock_work_user, thumbnail: mock_thumbnail(has_thumbnail),
      thumbnail_url: has_thumbnail ? 'https://via.placeholder.com/300x200' : nil,
      created_at: 1.week.ago
    )
  end
end

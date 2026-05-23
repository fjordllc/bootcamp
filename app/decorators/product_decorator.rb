# frozen_string_literal: true

module ProductDecorator
  delegate :skipped_practices, to: :user

  def meta_description
    "#{user.long_name}さんが提出した、" \
      "プラクティス「#{practice.title}」の提出物です。"
  end

  def after_submission_message?(viewer)
    user == viewer &&
      !wip? &&
      !checked? &&
      commented_users.mentor.empty?
  end

  def user_course_practice
    UserCoursePractice.new(user)
  end

  def practice_content_toggle_component
    PracticeContentToggle::PracticeContentToggleComponent.new(
      content_type: :practice,
      practice:
    )
  end

  def goal_content_toggle_component
    PracticeContentToggle::PracticeContentToggleComponent.new(
      content_type: :goal,
      practice:
    )
  end

  def skipped_practice_link(skipped_practice)
    skipped_practice_id = skipped_practice.practice.id
    display_practice = user.practices.find_by(id: skipped_practice_id) ||
                       skipped_practice.practice

    link_to practice_path(skipped_practice_id) do
      content_tag(
        :span,
        display_practice.title,
        class: 'category-practices-item__title-link-label'
      )
    end
  end

  def list_title(resource)
    case resource
    when Practice
      user.login_name
    when User
      practice.title
    end
  end
end

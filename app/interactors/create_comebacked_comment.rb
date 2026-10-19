# frozen_string_literal: true

class CreateComebackedComment
  include Interactor

  def call
    User.find_by(login_name: 'pjord').comments.create(
      description: I18n.t('talk.comeback'),
      commentable_id: Talk.find_by(user_id: context.user.id).id,
      commentable_type: 'Talk'
    )
  end
end

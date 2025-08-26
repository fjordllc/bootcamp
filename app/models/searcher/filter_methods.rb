# frozen_string_literal: true

module Searcher::FilterMethods
  private

  def filter_only_me(searchables, current_user)
    searchables.select do |s|
      case s
      when User then false
      when Practice then s.last_updated_user_id == current_user.id
      else s.respond_to?(:user_id) && s.user_id == current_user.id
      end
    end
  end

  def delete_private_comment!(searchables)
    (searchables || []).reject do |s|
      s.instance_of?(Comment) && s.commentable.class.in?([Talk, Inquiry, CorporateTrainingInquiry])
    end
  end
end

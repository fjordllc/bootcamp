# frozen_string_literal: true

class PjordRespondJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3
  discard_on ActiveJob::DeserializationError

  def perform(mentionable_type:, mentionable_id:)
    mentionable_class = mentionable_type.safe_constantize
    return if mentionable_class.nil?

    mentionable = mentionable_class.find_by(id: mentionable_id)
    return if mentionable.nil?

    pjord = Pjord.user
    return if pjord.nil?
    return if mentionable.sender == pjord
    return unless should_respond?(mentionable, pjord)

    response = Pjord::MentionResponseAgent.respond_to(mentionable)
    return if response.blank?

    reply(mentionable, pjord, response)
  end

  private

  def reply(mentionable, pjord, text)
    body = "@#{mentionable.sender.login_name} #{text}"

    case mentionable
    when Comment
      reply_as_comment(mentionable.commentable, pjord, body)
    when Answer
      reply_as_answer(mentionable.question, pjord, body)
    when Question
      reply_as_answer(mentionable, pjord, body)
    when Report, Product, PairWork, MicroReport
      reply_as_comment(mentionable, pjord, body)
    else
      Rails.logger.warn("[Pjord] Unsupported mentionable type: #{mentionable.class.name}")
    end
  end

  def reply_as_comment(commentable, pjord, body)
    Comment.create!(user: pjord, commentable: commentable, description: body)
  end

  def reply_as_answer(question, pjord, body)
    Answer.create!(user: pjord, question: question, description: body)
  end

  def mentions_pjord?(mentionable)
    mentionable.body&.match?(/(?<!\w)@#{Regexp.escape(Pjord::LOGIN_NAME)}(?!\w)/)
  end

  def should_respond?(mentionable, pjord)
    mentions_pjord?(mentionable) || product_comment_after_pjord_comment?(mentionable, pjord)
  end

  def product_comment_after_pjord_comment?(mentionable, pjord)
    return false unless mentionable.is_a?(Comment) && mentionable.commentable.is_a?(Product)

    mentionable.commentable.comments.where(user: pjord).where('created_at < ?', mentionable.created_at).exists?
  end
end

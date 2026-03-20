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
    return unless mentions_pjord?(mentionable)

    context = build_context(mentionable)
    response = Pjord.respond(message: mentionable.body, context: context)
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

  def build_context(mentionable)
    context = {}
    context[:location] = mentionable.where_mention if mentionable.respond_to?(:where_mention)
    context[:practice] = extract_practice(mentionable)
    context
  end

  def extract_practice(mentionable)
    case mentionable
    when Comment
      extract_practice_from_commentable(mentionable.commentable)
    when Answer
      mentionable.question.practice&.title
    when Question
      mentionable.practice&.title
    when Report
      mentionable.practices.map(&:title).join(', ').presence
    when Product
      mentionable.practice&.title
    end
  end

  def extract_practice_from_commentable(commentable)
    case commentable
    when Report
      commentable.practices.map(&:title).join(', ').presence
    when Product
      commentable.practice&.title
    end
  end
end

# frozen_string_literal: true

class PjordRespondJob < ApplicationJob
  queue_as :default

  def perform(mentionable_type:, mentionable_id:)
    mentionable = mentionable_type.constantize.find_by(id: mentionable_id)
    return if mentionable.nil?

    pjord = Pjord.user
    return if pjord.nil?
    return unless mentionable.body&.include?("@#{pjord.login_name}")

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
      reply_as_comment(pjord, mentionable.commentable, body)
    when Answer
      Answer.create!(user: pjord, question: mentionable.question, description: body)
    when Question
      Answer.create!(user: pjord, question: mentionable, description: body)
    when Report, Product
      reply_as_comment(pjord, mentionable, body)
    end
  end

  def reply_as_comment(pjord, commentable, body)
    Comment.create!(user: pjord, commentable: commentable, description: body)
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

# frozen_string_literal: true

class PjordRespondJob < ApplicationJob
  queue_as :default

  def perform(mentionable_type:, mentionable_id:)
    mentionable = mentionable_type.constantize.find(mentionable_id)
    pjord = Pjord.user
    return if pjord.nil?

    context = build_context(mentionable)
    response = Pjord.respond(message: mentionable.body, context: context)
    return if response.blank?

    reply(mentionable, pjord, response)
  end

  private

  def reply(mentionable, pjord, text)
    mention_back = "@#{mentionable.sender.login_name} "
    body = mention_back + text

    case mentionable
    when Comment
      Comment.create!(
        user: pjord,
        commentable: mentionable.commentable,
        description: body
      )
    when Answer
      # Q&Aの回答へのメンション → 同じ質問に新しい回答を投稿
      Answer.create!(
        user: pjord,
        question: mentionable.question,
        description: body
      )
    when Question
      # Q&Aの質問へのメンション → 回答として投稿
      Answer.create!(
        user: pjord,
        question: mentionable,
        description: body
      )
    when Report
      # 日報本文へのメンション → コメントとして投稿
      Comment.create!(
        user: pjord,
        commentable: mentionable,
        description: body
      )
    when Product
      # 提出物へのメンション → コメントとして投稿
      Comment.create!(
        user: pjord,
        commentable: mentionable,
        description: body
      )
    end
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

# frozen_string_literal: true

class Pjord::MentionResponseAgent < Pjord::Agent
  instructions

  def self.respond_to(mentionable)
    extract_public_response_body(new(inputs: { mentionable: }).ask(mentionable.body).content).presence
  end

  def self.practice_title(mentionable)
    case mentionable
    when Comment
      practice_title_from_commentable(mentionable.commentable)
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

  def self.practice_title_from_commentable(commentable)
    case commentable
    when Report
      commentable.practices.map(&:title).join(', ').presence
    when Product
      commentable.practice&.title
    end
  end
end

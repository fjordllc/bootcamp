# frozen_string_literal: true

class Pjord::MentionResponseAgent < Pjord::Agent
  instructions { Pjord::Agent.prompt_for('mention_response', Pjord::MentionResponseAgent.context_for(mentionable)) }

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

  def self.context_for(mentionable)
    sections = []
    location = mentionable.respond_to?(:where_mention) ? mentionable.where_mention : nil
    practice = practice_title(mentionable)
    sender_login_name = mentionable.sender&.login_name

    sections << "## 現在の場所\n#{location}" if location.present?
    sections << "## 関連プラクティス\n#{practice}" if practice.present?
    sections << "## メンションしてきたユーザー\nログイン名: #{sender_login_name}" if sender_login_name.present?
    sections.join("\n\n")
  end
end

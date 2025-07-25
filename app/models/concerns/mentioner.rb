# frozen_string_literal: true

module Mentioner
  def after_save_mention(new_mentions)
    return if instance_of?(Report)

    notify_users_found_by_mentions(new_mentions)
  end

  def new_mention_users
    find_users_from_login_names(extract_login_names_from_mentions(new_mentions))
  end

  def where_mention
    case self
    when Product
      "#{user.login_name}さんの提出物「#{practice[:title]}」"
    when Report
      "#{user.login_name}さんの日報「#{self[:title]}」"
    when Comment
      "#{target_of_comment(commentable.class, commentable)}へのコメント"
    when Answer
      "#{receiver.login_name}さんのQ&A「#{question[:title]}」へのコメント"
    when Question
      practice_title = practice ? practice[:title] : 'プラクティス選択なし'
      "#{user.login_name}さんのQ&A「#{practice_title}」"
    end
  end

  def body
    self[:body] || self[:description]
  end

  def notify_all_mention_user
    notify_users_found_by_mentions(mentions)
  end

  private

  def notify_users_found_by_mentions(mentions)
    notify_mentions(find_users_from_mentions(mentions))
  end

  def notify_mentions(receivers)
    return nil if instance_of?(Comment) && commentable.instance_of?(Talk) # protect mention in talk

    receivers.each do |receiver|
      ActivityDelivery.with(mentionable: self, receiver:).notify(:mentioned) if sender != receiver
    end
  end

  def find_users_from_login_names(names)
    User.where(login_name: names)
  end

  def find_users_from_mentions(mentions)
    names = extract_login_names_from_mentions(mentions)
    names.concat(User.mentor.map(&:login_name)) if names.include?('mentor')
    # find_users_from_login_names 内のwhereで重複は削除する
    find_users_from_login_names(names)
  end

  def extract_login_names_from_mentions(mentions)
    code_block_regexp = /```.*?```|`.*?`/m
    block_quotes_regexp = /^>.+?\n{2}|^>.+?\Z/m
    regexps = Regexp.union(code_block_regexp, block_quotes_regexp)
    mentionable_without_code_quotes = mentionable.gsub(regexps, '')
    mentions.map { |s| s.gsub(/@/, '') if mentionable_without_code_quotes.include?(s) }
  end

  def target_of_comment(commentable_class, commentable)
    {
      Report: "#{commentable.user.login_name}さんの日報「#{commentable.title}」",
      Product: "#{commentable.user.login_name}さんの#{commentable.title}",
      Event: "特別イベント「#{commentable.title}」",
      RegularEvent: "定期イベント「#{commentable.title}」",
      Page: "Docs「#{commentable.title}」",
      Announcement: "お知らせ「#{commentable.title}」"
    }[:"#{commentable_class}"]
  end
end

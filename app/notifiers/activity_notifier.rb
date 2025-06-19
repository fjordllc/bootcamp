# frozen_string_literal: true

class ActivityNotifier < ApplicationNotifier # rubocop:todo Metrics/ClassLength
  self.driver = ActivityDriver.new
  self.async_adapter = ActivityAsyncAdapter.new

  def graduated(params = {})
    params.merge!(@params)
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "🎉️ #{sender.login_name}さんが卒業しました！",
      kind: :graduated,
      sender:,
      receiver:,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

  def consecutive_sad_report(params = {})
    params.merge!(@params)
    report = params[:report]
    receiver = params[:receiver]

    notification(
      body: "#{report.user.login_name}さんが#{User::DEPRESSED_SIZE}回連続でsadアイコンの日報を提出しました。",
      kind: :consecutive_sad_report,
      sender: report.sender,
      receiver:,
      link: Rails.application.routes.url_helpers.polymorphic_path(report),
      read: false
    )
  end

  def assigned_as_checker(params = {})
    params.merge!(@params)
    product = params[:product]
    receiver = params[:receiver]

    notification(
      body: "#{product.user.login_name}さんの提出物#{product.title}の担当になりました。",
      kind: :assigned_as_checker,
      sender: product.sender,
      receiver:,
      link: Rails.application.routes.url_helpers.polymorphic_path(product),
      read: false
    )
  end

  def came_comment(params = {})
    params.merge!(@params)
    comment = params[:comment]
    receiver = params[:receiver]
    message = params[:message]
    link = params[:link]

    notification(
      body: message,
      kind: :came_comment,
      receiver:,
      sender: comment.sender,
      link:,
      read: false
    )
  end

  def came_question(params = {})
    params.merge!(@params)
    question = params[:question]
    receiver = params[:receiver]

    notification(
      body: "#{question.user.login_name}さんから質問「#{question.title}」が投稿されました。",
      kind: :came_question,
      receiver:,
      sender: question.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(question),
      read: false
    )
  end

  def submitted(params = {})
    params.merge!(@params)
    product = params[:product]
    receiver = params[:receiver]

    notification(
      body: "#{product.user.login_name}さんが#{product.title}を提出しました。",
      kind: :watching,
      sender: product.user,
      receiver:,
      link: Rails.application.routes.url_helpers.polymorphic_path(product),
      read: false
    )
  end

  def create_page(params = {})
    params.merge!(@params)
    page = params[:page]
    receiver = params[:receiver]

    notification(
      body: "#{page.user.login_name}さんがDocsに#{page.title}を投稿しました。",
      kind: :create_pages,
      sender: page.sender,
      receiver:,
      link: Rails.application.routes.url_helpers.polymorphic_path(page),
      read: false
    )
  end

  def first_report(params = {})
    params.merge!(@params)
    report = params[:report]
    receiver = params[:receiver]

    notification(
      body: "🎉 #{report.user.login_name}さんがはじめての日報を書きました！",
      kind: :first_report,
      receiver:,
      sender: report.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(report),
      read: false
    )
  end

  def retired(params = {})
    params.merge!(@params)
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "😢 #{sender.login_name}さんが退会しました。",
      kind: :retired,
      sender:,
      receiver:,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

  def hibernated(params = {})
    params.merge!(@params)
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "#{sender.login_name}さんが休会しました。",
      kind: :hibernated,
      sender:,
      receiver:,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

  def comebacked(params = {})
    params.merge!(@params)
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "#{sender.login_name}さんが休会から復帰しました！",
      kind: :comebacked,
      sender:,
      receiver:,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

  def signed_up(params = {})
    params.merge!(@params)
    sender = params[:sender]
    sender_roles = params[:sender_roles].empty? ? '' : "(#{params[:sender_roles]})"
    receiver = params[:receiver]

    notification(
      body: "🎉 #{sender.login_name}さん#{sender_roles}が新しく入会しました！",
      kind: :signed_up,
      sender:,
      receiver:,
      link: Rails.application.routes.url_helpers.polymorphic_path(sender),
      read: false
    )
  end

  def mentioned(params = {})
    params.merge!(@params)
    mentionable = params[:mentionable]
    receiver = params[:receiver]

    notification(
      body: "#{mentionable.where_mention}で#{mentionable.sender.login_name}さんからメンションがきました。",
      kind: :mentioned,
      receiver:,
      sender: mentionable.sender,
      link: mentionable.path,
      read: false
    )
  end

  def following_report(params = {})
    params.merge!(@params)
    report = params[:report]
    receiver = params[:receiver]

    notification(
      body: "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！",
      kind: :following_report,
      receiver:,
      sender: report.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(report),
      read: false
    )
  end

  def came_answer(params = {})
    params.merge!(@params)
    answer = params[:answer]

    notification(
      body: "#{answer.user.login_name}さんから回答がありました。",
      kind: :answered,
      receiver: answer.receiver,
      sender: answer.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(answer.question),
      read: false
    )
  end

  def checked(params = {})
    params.merge!(@params)
    check = params[:check]
    receiver = params[:receiver]

    notification(
      body: "#{check.sender.login_name}さんが#{check.checkable.title}を確認しました。",
      kind: :checked,
      receiver:,
      sender: check.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(check.checkable),
      read: false
    )
  end

  def trainee_report(params = {})
    params.merge!(@params)
    report = params[:report]
    receiver = params[:receiver]

    notification(
      body: "#{report.user.login_name}さんが日報【 #{report.title} 】を書きました！",
      kind: :trainee_report,
      receiver:,
      sender: report.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(report),
      read: false
    )
  end

  def product_update(params = {})
    params.merge!(@params)
    product = params[:product]
    receiver = params[:receiver]

    notification(
      body: "#{product.user.login_name}さんの「#{product.practice.title}」の提出物が更新されました。",
      kind: :product_update,
      receiver:,
      sender: product.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(product),
      read: false
    )
  end

  def watching_notification(params = {})
    params.merge!(@params)
    watchable = params[:watchable]
    receiver = params[:receiver]
    sender = params[:sender]
    action = watchable.instance_of?(Question) ? '回答' : 'コメント'

    notification(
      body: "#{watchable.user.login_name}さんの#{watchable.notification_title}に#{sender.login_name}さんが#{action}しました。",
      kind: :watching,
      receiver:,
      sender:,
      link: Rails.application.routes.url_helpers.polymorphic_path(watchable),
      read: false
    )
  end

  def update_regular_event(params = {})
    params.merge!(@params)
    regular_event = params[:regular_event]
    receiver = params[:receiver]
    sender = params[:sender]

    notification(
      body: "定期イベント【#{regular_event.title}】が更新されました。",
      kind: :regular_event_updated,
      receiver:,
      sender:,
      link: Rails.application.routes.url_helpers.polymorphic_path(regular_event),
      read: false
    )
  end

  def no_correct_answer(params = {})
    params.merge!(@params)
    question = params[:question]
    receiver = params[:receiver]

    notification(
      body: "Q&A「#{question.title}」のベストアンサーがまだ選ばれていません。",
      kind: :no_correct_answer,
      receiver:,
      sender: question.sender,
      link: Rails.application.routes.url_helpers.polymorphic_path(question),
      read: false
    )
  end

  def chose_correct_answer(params = {})
    params.merge!(@params)
    answer = params[:answer]
    receiver = params[:receiver]

    notification(
      body: "#{answer.receiver.login_name}さんの質問【 #{answer.question.title} 】で#{answer.sender.login_name}さんの回答がベストアンサーに選ばれました。",
      kind: :chose_correct_answer,
      receiver:,
      sender: answer.receiver,
      link: Rails.application.routes.url_helpers.polymorphic_path(answer.question),
      read: false
    )
  end

  def moved_up_event_waiting_user(params = {})
    params.merge!(@params)
    event = params[:event]
    receiver = params[:receiver]

    notification(
      body: "#{event.title}で、補欠から参加に繰り上がりました。",
      kind: :moved_up_event_waiting_user,
      receiver:,
      sender: event.user,
      link: Rails.application.routes.url_helpers.polymorphic_path(event),
      read: false
    )
  end

  def create_article(params = {})
    params.merge!(@params)
    article = params[:article]
    receiver = params[:receiver]

    notification(
      body: "#{article.user.login_name}さんがブログに「#{article.title}」を投稿しました。",
      kind: :create_article,
      receiver:,
      sender: article.user,
      link: Rails.application.routes.url_helpers.polymorphic_path(article),
      read: false
    )
  end

  def added_work(params = {})
    params.merge!(@params)
    work = params[:work]
    receiver = params[:receiver]
    sender = work.user

    notification(
      body: "#{sender.login_name}さんがポートフォリオに作品「#{work.title}」を追加しました。",
      kind: :added_work,
      receiver:,
      sender:,
      link: Rails.application.routes.url_helpers.polymorphic_path(work),
      read: false
    )
  end

  def came_inquiry(params = {})
    params.merge!(@params)
    inquiry = params[:inquiry]
    sender = params[:sender]
    receiver = params[:receiver]

    notification(
      body: "#{inquiry.name}さんから問い合わせがありました。",
      kind: :came_inquiry,
      receiver:,
      sender:,
      link: Rails.application.routes.url_helpers.admin_inquiry_path(inquiry),
      read: false
    )
  end
end

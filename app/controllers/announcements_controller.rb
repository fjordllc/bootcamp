# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :set_announcement, only: %i[show edit update destroy]
  before_action :rewrite_announcement, only: %i[update]

  def index; end

  def show; end

  def new
    @announcement = Announcement.new(target: 'students')

    if params[:id]
      announcement = Announcement.find(params[:id])
      @announcement.title       = announcement.title
      @announcement.description = announcement.description
      @announcement.target = announcement.target
      flash.now[:notice] = 'お知らせをコピーしました。'
    elsif params[:page_id]
      page = Page.find(params[:page_id])
      template = MessageTemplate.load('page_announcements.yml', params: { page: page })
      @announcement.title       = template['title']
      @announcement.description = template['description']
    elsif params[:event_id]
      event = Event.find(params[:event_id])
      template = MessageTemplate.load('event_announcements.yml', params: { event: event })
      @announcement.title       = template['title']
      @announcement.description = template['description']
    elsif params[:regular_event_id]
      set_template_for_regular_event
    end
  end

  def edit; end

  def update
    set_wip

    if @announcement.update(announcement_params)
      Newspaper.publish(:announcement_update, @announcement)
      redirect_to @announcement, notice: notice_message(@announcement)
    else
      render :edit
    end
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
    set_wip
    if @announcement.save
      Newspaper.publish(:announcement_create, @announcement)
      redirect_to @announcement, notice: notice_message(@announcement)
    else
      render :new
    end
  end

  def destroy
    @announcement.destroy
    Newspaper.publish(:announcement_destroy, @announcement)
    redirect_to announcements_path, notice: 'お知らせを削除しました'
  end

  private

  def announcement_params
    params.require(:announcement).permit(:title, :description, :target)
  end

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def set_wip
    @announcement.wip = (params[:commit] == 'WIP')
  end

  def notice_message(announcement)
    case params[:action]
    when 'create'
      announcement.wip? ? 'お知らせをWIPとして保存しました。' : 'お知らせを作成しました。'
    when 'update'
      announcement.wip? ? 'お知らせをWIPとして保存しました。' : 'お知らせを更新しました。'
    end
  end

  def rewrite_announcement
    return unless conflict?

    set_entered_announcement

    flash.now[:alert] = '別の人がお知らせを更新していたので更新できませんでした。'
    render :edit
  end

  def conflict?
    Time.zone.parse(params['announcement']['updated_at']).utc.floor != Announcement.find(params[:id]).updated_at.utc.floor
  end

  def set_entered_announcement
    @announcement.assign_attributes(updated_at: params['announcement']['updated_at'], \
                                    title: params['announcement']['title'], \
                                    description: params['announcement']['description'], \
                                    target: params['announcement']['target'])
  end

  def set_template_for_regular_event
    regular_event = RegularEvent.find(params[:regular_event_id])
    organizers = regular_event.organizers.map do |organizer|
      "  - @#{organizer.login_name}"
    end.join("\n")
    holding_cycles = ActiveDecorator::Decorator.instance.decorate(regular_event).holding_cycles
    hold_national_holiday = "(祝日#{regular_event.hold_national_holiday ? 'も開催' : 'は休み'})"
    @announcement.title       = "#{regular_event.title}を開催します🎉"
    @announcement.description = <<~DESCRIPTION_TEMPLATE
      <!-- このテキストを編集してください -->

      #{regular_event.title}を開催します🎉

      - 開催日
        - #{holding_cycles} #{hold_national_holiday}
      - 開催時間
        - #{l regular_event.start_at, format: :time_only} 〜 #{l regular_event.end_at, format: :time_only}
      - 主催者
      #{organizers}

      ---

      #{regular_event.description}

      ## 参加登録はこちら
      #{regular_event_url(regular_event)}

      ---
    DESCRIPTION_TEMPLATE
  end
end

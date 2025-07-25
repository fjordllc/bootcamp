# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  PAGER_NUMBER = 25

  before_action :set_announcement, only: %i[show edit update destroy]
  before_action :rewrite_announcement, only: %i[update]

  def index
    @announcements = Announcement.with_avatar
                                 .preload(:comments)
                                 .order(published_at: :desc, created_at: :desc)
                                 .page(params[:page])
                                 .per(PAGER_NUMBER)
  end

  def show
    Footprint.find_or_create_for(@announcement, current_user)
    @footprints = Footprint.fetch_for_resource(@announcement)
    @announcements = Announcement.with_avatar.where(wip: false).order(published_at: :desc).limit(10)
    @comments = @announcement.comments.order(:created_at)
  end

  def new
    @announcement = Announcement.new(target: 'students')

    if params[:id]
      @announcement = Announcement.copy_announcement(params[:id])
      flash.now[:notice] = 'お知らせをコピーしました。'
    elsif params[:page_id]
      page = Page.find(params[:page_id])
      @announcement = Announcement.copy_template_by_resource('page_announcements.yml', page:)
    elsif params[:event_id]
      event = Event.find(params[:event_id])
      @announcement = Announcement.copy_template_by_resource('event_announcements.yml', event:)
    elsif params[:regular_event_id]
      regular_event = RegularEvent.find(params[:regular_event_id])
      params = { regular_event:,
                 organizers: regular_event.organizers.map { |organizer| "@#{organizer.login_name}" }.join("\n    - "),
                 holding_cycles: ActiveDecorator::Decorator.instance.decorate(regular_event).holding_cycles,
                 hold_national_holiday: "(祝日#{regular_event.hold_national_holiday ? 'も開催' : 'は休み'})" }
      @announcement = Announcement.copy_template_by_resource('regular_event_announcements.yml', params)
    end
  end

  def edit; end

  def update
    set_wip

    if @announcement.update(announcement_params)
      ActiveSupport::Notifications.instrument('announcement.update', announcement: @announcement)
      redirect_to Redirection.determin_url(self, @announcement), notice: notice_message(@announcement)
    else
      render :edit
    end
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
    set_wip
    if @announcement.save
      ActiveSupport::Notifications.instrument('announcement.create', announcement: @announcement)
      redirect_to Redirection.determin_url(self, @announcement), notice: notice_message(@announcement)
    else
      render :new
    end
  end

  def destroy
    @announcement.destroy
    ActiveSupport::Notifications.instrument('announcement.destroy', announcement: @announcement)
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
end

# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :set_announcement, only: %i[show edit update destroy]
  before_action :rewrite_announcement, only: %i[update]

  def index; end

  def show; end

  def new
    @announcement = Announcement.new(target: 'students')

    if params[:id]
      copy_announcement(params[:id])
    elsif params[:page_id]
      page = Page.find(params[:page_id])
      copy_template_by_resource('page_announcements.yml', page: page)
    elsif params[:event_id]
      event = Event.find(params[:event_id])
      copy_template_by_resource('event_announcements.yml', event: event)
    elsif params[:regular_event_id]
      regular_event = RegularEvent.find(params[:regular_event_id])
      organizers = regular_event.organizers.map { |organizer| "@#{organizer.login_name}" }.join("\n    - ")
      holding_cycles = ActiveDecorator::Decorator.instance.decorate(regular_event).holding_cycles
      hold_national_holiday = "(祝日#{regular_event.hold_national_holiday ? 'も開催' : 'は休み'})"
      copy_template_by_resource('regular_event_announcements.yml',
                                regular_event: regular_event,
                                organizers: organizers,
                                holding_cycles: holding_cycles,
                                hold_national_holiday: hold_national_holiday)
    end
  end

  def edit; end

  def update
    set_wip

    if @announcement.update(announcement_params)
      Newspaper.publish(:announcement_update, @announcement)
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
      Newspaper.publish(:announcement_create, @announcement)
      redirect_to Redirection.determin_url(self, @announcement), notice: notice_message(@announcement)
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

  def copy_announcement(announcement_id)
    announcement = Announcement.find(announcement_id)
    @announcement.title       = announcement.title
    @announcement.description = announcement.description
    @announcement.target = announcement.target
    flash.now[:notice] = 'お知らせをコピーしました。'
  end

  def copy_template_by_resource(template_file, params = {})
    template = MessageTemplate.load(template_file, params: params)
    @announcement.title       = template['title']
    @announcement.description = template['description']
  end
end
